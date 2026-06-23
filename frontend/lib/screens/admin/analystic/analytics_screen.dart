import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/dark_mode_helpers.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analytics', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Track platform performance and usage trends', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.5,
                children: [
                  _summaryCard(context, 'Page Views', '482,920', '+8.4%', const Color(0xFF3B82F6)),
                  _summaryCard(context, 'Avg. Session', '4m 32s', '+1.2%', const Color(0xFF10B981)),
                  _summaryCard(context, 'Bounce Rate', '32.4%', '-3.1%', const Color(0xFFEF4444), negative: true),
                  _summaryCard(context, 'New Signups', '1,284', '+22.6%', const Color(0xFF8B5CF6)),
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
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(days[value.toInt() % 7], style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(7, (i) {
                            final values = [60.0, 75.0, 50.0, 90.0, 80.0, 65.0, 95.0];
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: values[i],
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
                    Text('Traffic Sources', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 36,
                          sections: [
                            PieChartSectionData(color: const Color(0xFF6366F1), value: 45, title: '45%', radius: 46, titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            PieChartSectionData(color: const Color(0xFF14B8A6), value: 30, title: '30%', radius: 46, titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            PieChartSectionData(color: const Color(0xFFF59E0B), value: 15, title: '15%', radius: 46, titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            PieChartSectionData(color: const Color(0xFFEC4899), value: 10, title: '10%', radius: 46, titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _legendItem(const Color(0xFF6366F1), 'Direct', '45%', context),
                    _legendItem(const Color(0xFF14B8A6), 'Search', '30%', context),
                    _legendItem(const Color(0xFFF59E0B), 'Social', '15%', context),
                    _legendItem(const Color(0xFFEC4899), 'Referral', '10%', context),
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

  Widget _summaryCard(BuildContext context, String title, String value, String change, Color color, {bool negative = false}) {
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
