import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/dark_mode_helpers.dart';
import '../../../services/supabase_data_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _service = SupabaseDataService();
  bool _loading = true;

  Map<String, dynamic> _stats = {};

  // Bar chart data derived from `daily_activity`.
  List<double> _barValues = List.filled(7, 0);
  List<String> _barLabels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _service.getAdminStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _buildDailyBars(stats);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int _asInt(dynamic v) => v is num ? v.toInt() : 0;

  int _si(String k) => (_stats[k] is num) ? (_stats[k] as num).toInt() : 0;

  final _numFmt = NumberFormat.decimalPattern();

  /// Computes a month-over-month delta chip value. Returns null when there is no
  /// meaningful change to show (both periods empty). Returns ('New', false) when
  /// there was no prior activity but there is now.
  (String, bool)? _delta(int now, int prev) {
    if (now == 0 && prev == 0) return null;
    if (prev == 0 && now > 0) return ('New', false);
    final pct = (now - prev) / prev * 100.0;
    return ('${pct.abs().toStringAsFixed(1)}%', pct < 0);
  }

  /// Produces 7 bars for the last 7 calendar days (missing days -> 0), labelled
  /// with the weekday abbreviation. Bar heights are normalized to 0-100 by the
  /// max daily count so the chart's proportional visuals stay intact.
  void _buildDailyBars(Map<String, dynamic> stats) {
    final raw = (stats['activity_14d'] as List?) ?? const [];
    final counts = <String, int>{};
    for (final e in raw) {
      if (e is Map) {
        final day = e['day']?.toString();
        final parsed = day == null ? null : DateTime.tryParse(day);
        if (parsed != null) {
          final key = DateFormat('yyyy-MM-dd').format(parsed);
          counts[key] = _asInt(e['count']);
        }
      }
    }

    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i));
      return d;
    });

    final rawCounts =
        days.map((d) => counts[DateFormat('yyyy-MM-dd').format(d)] ?? 0).toList();
    final maxCount = rawCounts.fold<int>(0, (m, c) => c > m ? c : m);

    _barValues = rawCounts
        .map((c) => maxCount == 0 ? 0.0 : c / maxCount * 100.0)
        .toList();
    _barLabels = days.map((d) => DateFormat('EEE').format(d)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analytics', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Track platform performance and usage trends', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14)),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: D.card(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: D.bd(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: D.t2(context)),
                      const SizedBox(width: 6),
                      Text('Last 30 days', style: GoogleFonts.poppins(color: D.t1(context), fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: D.t2(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

              final usersDelta = _delta(_si('users_this_month'), _si('users_prev_month'));
              final aiRequests = _si('total_conversations') + _si('total_images') + _si('total_speech') + _si('total_translations');
              final requestsDelta = _delta(_si('requests_this_month'), _si('requests_prev_month'));
              final avgRating = _si('reviews_count') > 0 ? (_stats['avg_rating'] as num).toStringAsFixed(1) : '—';

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.5,
                children: [
                  _summaryCard(context, 'Total Users', _numFmt.format(_si('total_users')), usersDelta?.$1, const Color(0xFF3B82F6), negative: usersDelta?.$2 ?? false),
                  _summaryCard(context, 'Active (7d)', _numFmt.format(_si('active_users_7d')), null, const Color(0xFF10B981)),
                  _summaryCard(context, 'AI Requests', _numFmt.format(aiRequests), requestsDelta?.$1, const Color(0xFFF59E0B), negative: requestsDelta?.$2 ?? false),
                  _summaryCard(context, 'Avg Rating', avgRating, null, const Color(0xFF8B5CF6)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              final barChart = Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: D.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: D.bd(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requests Over Time', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(color: D.bd(context), strokeWidth: 0.5),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  final label = (i >= 0 && i < _barLabels.length) ? _barLabels[i] : '';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(7, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: _barValues[i],
                                  color: const Color(0xFF6C63FF),
                                  width: 16,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              const serviceColors = [
                Color(0xFF3B82F6),
                Color(0xFF10B981),
                Color(0xFFF59E0B),
                Color(0xFF8B5CF6),
              ];
              final breakdown = (_stats['service_breakdown'] as List?) ?? const [];
              final services = <(String, int, Color)>[];
              for (var i = 0; i < breakdown.length; i++) {
                final e = breakdown[i];
                if (e is Map) {
                  final label = e['label']?.toString() ?? '';
                  final count = _asInt(e['count']);
                  services.add((label, count, serviceColors[i % serviceColors.length]));
                }
              }
              final serviceTotal = services.fold<int>(0, (s, e) => s + e.$2);

              final pieChart = Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: D.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: D.bd(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requests by service', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
                    const SizedBox(height: 12),
                    if (serviceTotal == 0)
                      SizedBox(
                        height: 180,
                        child: Center(
                          child: Text('No usage yet', style: GoogleFonts.poppins(fontSize: 13, color: D.t2(context))),
                        ),
                      )
                    else ...[
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: [
                              for (final s in services)
                                if (s.$2 > 0)
                                  PieChartSectionData(
                                    color: s.$3,
                                    value: s.$2.toDouble(),
                                    title: '${(s.$2 / serviceTotal * 100).round()}%',
                                    radius: 46,
                                    titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final s in services)
                        if (s.$2 > 0)
                          _legendItem(s.$3, s.$1, '${(s.$2 / serviceTotal * 100).round()}%', context),
                    ],
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: barChart),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: pieChart),
                  ],
                );
              } else {
                return Column(children: [barChart, const SizedBox(height: 16), pieChart]);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, String title, String value, String? change, Color color, {bool negative = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: D.bd(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
          ),
          if (change != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: (negative ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(children: [
                    Icon(negative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 10, color: negative ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                    const SizedBox(width: 2),
                    Text(change, style: GoogleFonts.poppins(color: negative ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(width: 6),
                Flexible(child: Text('vs last month', style: GoogleFonts.poppins(color: D.t3(context), fontSize: 10), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String percentage, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: D.t1(context)))),
          Text(percentage, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: D.t1(context))),
        ],
      ),
    );
  }
}
