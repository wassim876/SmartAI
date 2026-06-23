import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';

class UserGrowthChart extends StatelessWidget {
  const UserGrowthChart({super.key});

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
                Text('Last 30 days', style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
                Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: D.t2(context)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true, drawVerticalLine: false, horizontalInterval: 1,
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
                      if (value.toInt() % 5 == 0) {
                        return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text('${value.toInt()}', style: GoogleFonts.poppins(color: D.t3(context), fontSize: 10)));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, interval: 1, reservedSize: 40,
                    getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text('${value.toInt()}', style: GoogleFonts.poppins(color: D.t3(context), fontSize: 10))),
                  ),
                ),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: D.bd(context))),
              minX: 0, maxX: 30, minY: 0, maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: [FlSpot(0, 1), FlSpot(5, 2), FlSpot(10, 1.5), FlSpot(15, 3), FlSpot(20, 2.5), FlSpot(25, 4), FlSpot(30, 5)],
                  isCurved: true, color: const Color(0xFF6C63FF), barWidth: 3, isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: const Color(0xFF6C63FF).withValues(alpha: 0.08)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
