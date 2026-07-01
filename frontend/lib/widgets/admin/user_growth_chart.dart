import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';

class UserGrowthChart extends StatelessWidget {
  const UserGrowthChart({super.key, required this.data});

  final List<dynamic> data;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _shortMonth(dynamic monthValue) {
    final str = (monthValue ?? '').toString();
    final parts = str.split('-');
    if (parts.length >= 2) {
      final m = int.tryParse(parts[1]);
      if (m != null && m >= 1 && m <= 12) return _monthNames[m - 1];
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text('User Growth', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: D.hover(context), borderRadius: BorderRadius.circular(8), border: Border.all(color: D.bd(context))),
              child: Row(children: [
                Text('Last 6 months', style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
                Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: D.t2(context)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: data.isEmpty ? _buildEmpty(context) : _buildChart(context),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Text('No data yet',
          style: GoogleFonts.poppins(fontSize: 13, color: D.t3(context))),
    );
  }

  Widget _buildChart(BuildContext context) {
    final counts = data
        .map((e) => ((e is Map ? e['count'] : null) ?? 0) as num)
        .map((n) => n.toDouble())
        .toList();

    final spots = <FlSpot>[
      for (int i = 0; i < counts.length; i++) FlSpot(i.toDouble(), counts[i]),
    ];

    final int n = counts.length;
    final double maxX = (n - 1).clamp(1, double.maxFinite).toDouble();
    final double maxCount =
        counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
    final double maxY = (maxCount * 1.2).clamp(1, double.maxFinite).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: D.bd(context), strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 30, interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= data.length || (value - i).abs() > 0.01) {
                  return const SizedBox();
                }
                final label = _shortMonth(data[i] is Map ? (data[i] as Map)['month'] : null);
                return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(label, style: GoogleFonts.poppins(color: D.t3(context), fontSize: 10)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 40,
              getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text('${value.toInt()}', style: GoogleFonts.poppins(color: D.t3(context), fontSize: 10))),
            ),
          ),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: D.bd(context))),
        minX: 0, maxX: maxX, minY: 0, maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true, color: const Color(0xFF6C63FF), barWidth: 3, isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF6C63FF).withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }
}
