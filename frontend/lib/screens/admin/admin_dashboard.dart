import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/dark_mode_helpers.dart';
import '../../services/supabase_data_service.dart';
import '../../widgets/admin/ai_services_chart.dart';
import '../../widgets/admin/user_growth_chart.dart';
import '../../widgets/admin/recent_activity_list.dart';

/// Admin dashboard — a responsive, real-data overview of the SmartAI app.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const _accent = Color(0xFF6C63FF);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _violet = Color(0xFF8B5CF6);
  static const _pink = Color(0xFFEC4899);

  final _fmt = NumberFormat.decimalPattern();

  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await SupabaseDataService().getAdminStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  // ---- data coercion helpers ----
  int _i(String k) => (_stats?[k] is num) ? (_stats![k] as num).toInt() : 0;
  double _d(String k) => (_stats?[k] is num) ? (_stats![k] as num).toDouble() : 0;
  List<dynamic> _l(String k) =>
      (_stats?[k] is List) ? (_stats![k] as List) : const [];

  int get _aiRequests =>
      _i('total_conversations') +
      _i('total_images') +
      _i('total_speech') +
      _i('total_translations');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final bool mobile = w < 700;
          final bool desktop = w >= 1120;

          if (_loading) {
            return const Center(
                child: CircularProgressIndicator(color: _accent));
          }
          if (_error != null) return _errorView();

          return RefreshIndicator(
            color: _accent,
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(mobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(mobile),
                  SizedBox(height: mobile ? 18 : 24),
                  _kpiGrid(w),
                  SizedBox(height: mobile ? 16 : 20),
                  _chartsArea(desktop, mobile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 40, color: D.t3(context)),
          const SizedBox(height: 12),
          Text('Couldn\'t load dashboard',
              style: GoogleFonts.poppins(
                  color: D.t1(context), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(_error ?? '',
              style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12)),
          const SizedBox(height: 14),
          FilledButton.tonal(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  // ============================ HEADER ============================
  Widget _header(bool mobile) {
    return Row(
      children: [
        Container(
          width: mobile ? 44 : 50,
          height: mobile ? 44 : 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_accent, Color(0xFF8B7CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: _accent.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8))
            ],
          ),
          child:
              const Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: GoogleFonts.poppins(
                      fontSize: mobile ? 20 : 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: D.t1(context))),
              Row(children: [
                Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: _green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                      '${_fmt.format(_i('active_users_7d'))} active this week',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: D.t2(context), fontSize: mobile ? 12 : 13.5)),
                ),
              ]),
            ],
          ),
        ),
        _iconBtn(Icons.refresh_rounded, _load),
        const SizedBox(width: 8),
        _iconBtn(Icons.notifications_none_rounded,
            () => Navigator.pushNamed(context, '/admin/notifications')),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: D.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: D.bd(context))),
          child: Icon(icon, size: 20, color: D.t2(context)),
        ),
      ),
    );
  }

  // ============================ KPIs ============================
  Widget _kpiGrid(double w) {
    final total = _i('total_users');
    final premium = _i('premium_users');
    final conversion =
        total > 0 ? (premium / total * 100).toStringAsFixed(1) : '0';

    final cards = <Widget>[
      _kpiCard(
        icon: Icons.people_alt_rounded,
        color: _blue,
        label: 'Total Users',
        value: _fmt.format(total),
        delta: _delta(_i('users_this_month'), _i('users_prev_month')),
        footnote: '+${_fmt.format(_i('new_users_today'))} today',
      ),
      _kpiCard(
        icon: Icons.bolt_rounded,
        color: _green,
        label: 'Active (7d)',
        value: _fmt.format(_i('active_users_7d')),
        footnote: 'of ${_fmt.format(total)} users',
      ),
      _kpiCard(
        icon: Icons.workspace_premium_rounded,
        color: _amber,
        label: 'Premium',
        value: _fmt.format(premium),
        footnote: '$conversion% conversion',
      ),
      _kpiCard(
        icon: Icons.auto_awesome_rounded,
        color: _violet,
        label: 'AI Requests',
        value: _fmt.format(_aiRequests),
        delta: _delta(_i('requests_this_month'), _i('requests_prev_month')),
        footnote: 'all-time',
      ),
      _kpiCard(
        icon: Icons.star_rounded,
        color: _pink,
        label: 'Avg Rating',
        value: _i('reviews_count') > 0 ? _d('avg_rating').toStringAsFixed(1) : '—',
        footnote: '${_fmt.format(_i('reviews_count'))} reviews',
      ),
    ];

    final cross = w >= 1120 ? 5 : (w >= 760 ? 3 : 2);
    final ratio = w >= 1120 ? 1.4 : (w >= 760 ? 1.4 : 1.1);
    return GridView.count(
      crossAxisCount: cross,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: ratio,
      children: cards,
    );
  }

  Widget _kpiCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    _Delta? delta,
    String? footnote,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 19),
            ),
            const Spacer(),
            if (delta != null) _deltaChip(delta),
          ]),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: D.t1(context))),
          ),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: D.t1(context))),
          if (footnote != null)
            Text(footnote,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    GoogleFonts.poppins(fontSize: 11, color: D.t3(context))),
        ],
      ),
    );
  }

  Widget _deltaChip(_Delta d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: d.color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(d.icon, size: 12, color: d.color),
        const SizedBox(width: 2),
        Text(d.label,
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: d.color)),
      ]),
    );
  }

  _Delta? _delta(int now, int prev) {
    if (prev == 0 && now == 0) return null;
    if (prev == 0) {
      return _Delta('New', _green, Icons.arrow_upward_rounded);
    }
    final pct = (now - prev) / prev * 100;
    if (pct.abs() < 0.05) {
      return _Delta('0%', D.t3(context), Icons.remove_rounded);
    }
    final up = pct >= 0;
    return _Delta('${pct.abs().toStringAsFixed(1)}%', up ? _green : _pink,
        up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
  }

  // ============================ CHARTS AREA ============================
  Widget _chartsArea(bool desktop, bool mobile) {
    final gap = SizedBox(height: mobile ? 16 : 20);
    return Column(
      children: [
        _twoUp(
          _panel('Activity — last 14 days',
              _activityTrend(), trailing: _requestsBadge()),
          _panel('AI Services usage',
              AIServicesChart(breakdown: _l('service_breakdown'))),
          desktop,
          leftFlex: 3,
          rightFlex: 2,
          height: mobile ? 260 : 320,
        ),
        gap,
        _twoUp(
          _panel('User growth', UserGrowthChart(data: _l('user_growth'))),
          _panel('Recent activity',
              RecentActivityList(items: _l('recent_activity'))),
          desktop,
          leftFlex: 3,
          rightFlex: 2,
          height: mobile ? 280 : 320,
        ),
        gap,
        _twoUp(
          _panel('Top users', _topUsers()),
          _panel('Recent reviews', _recentReviews()),
          desktop,
          leftFlex: 1,
          rightFlex: 1,
          height: mobile ? 300 : 340,
        ),
      ],
    );
  }

  /// Two panels side-by-side on wide layouts, stacked on narrow ones.
  Widget _twoUp(Widget left, Widget right, bool wide,
      {int leftFlex = 1, int rightFlex = 1, required double height}) {
    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: leftFlex, child: SizedBox(height: height, child: left)),
            const SizedBox(width: 20),
            Expanded(
                flex: rightFlex, child: SizedBox(height: height, child: right)),
          ],
        ),
      );
    }
    return Column(children: [
      SizedBox(height: height, child: left),
      SizedBox(height: height < 300 ? 300 : height, child: right),
    ]..insert(1, const SizedBox(height: 16)));
  }

  Widget _requestsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Text('${_fmt.format(_aiRequests)} total',
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: _accent)),
    );
  }

  // ---- activity trend (area line chart, 14 days) ----
  Widget _activityTrend() {
    final byDay = <String, double>{};
    for (final e in _l('activity_14d')) {
      byDay[e['day'].toString()] = (e['count'] as num?)?.toDouble() ?? 0;
    }
    final now = DateTime.now();
    final df = DateFormat('yyyy-MM-dd');
    final spots = <FlSpot>[];
    for (int i = 0; i < 14; i++) {
      final day = now.subtract(Duration(days: 13 - i));
      spots.add(FlSpot(i.toDouble(), byDay[df.format(day)] ?? 0));
    }
    final maxY =
        math.max(4.0, spots.map((s) => s.y).reduce(math.max) * 1.25);

    if (spots.every((s) => s.y == 0)) {
      return _emptyState('No activity yet');
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 6),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 13,
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: D.bd(context), strokeWidth: 0.5)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (v, m) => v == v.roundToDouble()
                        ? Text('${v.toInt()}',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: D.t3(context)))
                        : const SizedBox())),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  if (i % 3 != 0) return const SizedBox();
                  final day = now.subtract(Duration(days: 13 - i));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(DateFormat('d/M').format(day),
                        style: GoogleFonts.poppins(
                            fontSize: 9.5, color: D.t3(context))),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _accent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _accent.withValues(alpha: 0.25),
                    _accent.withValues(alpha: 0.0)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- top users ----
  Widget _topUsers() {
    final users = _l('top_users');
    if (users.isEmpty) return _emptyState('No users yet');
    const palette = [_blue, _green, _amber, _violet, _pink];
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final u = users[i] as Map;
        final name = (u['display_name'] ?? u['email'] ?? 'User').toString();
        final count = (u['message_count'] as num?)?.toInt() ?? 0;
        final premium = u['is_premium'] == true;
        final color = palette[i % palette.length];
        return Row(children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: D.t1(context))),
                    ),
                    if (premium) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.workspace_premium_rounded,
                          size: 13, color: _amber),
                    ],
                  ]),
                  Text('${_fmt.format(count)} messages',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: D.t3(context))),
                ]),
          ),
          Text('#${i + 1}',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: D.t3(context))),
        ]);
      },
    );
  }

  // ---- recent reviews ----
  Widget _recentReviews() {
    final reviews = _l('recent_reviews');
    if (reviews.isEmpty) return _emptyState('No reviews yet');
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: reviews.length,
      separatorBuilder: (_, __) => Divider(color: D.bd(context), height: 18),
      itemBuilder: (context, i) {
        final r = reviews[i] as Map;
        final rating = (r['rating'] as num?)?.toInt() ?? 0;
        final name = (r['display_name'] ?? r['email'] ?? 'User').toString();
        final comment = (r['comment'] ?? '').toString();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              for (int s = 0; s < 5; s++)
                Icon(s < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: s < rating ? _amber : D.t3(context)),
              const Spacer(),
              Text(_relative(r['created_at']),
                  style:
                      GoogleFonts.poppins(fontSize: 10, color: D.t3(context))),
            ]),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      GoogleFonts.poppins(fontSize: 12.5, color: D.t1(context))),
            ],
            const SizedBox(height: 2),
            Text('— $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
          ],
        );
      },
    );
  }

  // ============================ SHARED ============================
  BoxDecoration _panelDeco() => BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: D.bd(context)),
        boxShadow: [
          BoxShadow(
            color: D.isDark(context)
                ? Colors.black.withValues(alpha: 0.18)
                : const Color(0xFF1A1464).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  Widget _panel(String title, Widget child, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: D.t1(context))),
            ),
            if (trailing != null) trailing,
          ]),
          const SizedBox(height: 14),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Text(msg,
          style: GoogleFonts.poppins(fontSize: 12.5, color: D.t3(context))),
    );
  }

  String _relative(dynamic iso) {
    final dt = DateTime.tryParse(iso?.toString() ?? '');
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _Delta {
  final String label;
  final Color color;
  final IconData icon;
  _Delta(this.label, this.color, this.icon);
}
