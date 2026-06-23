import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';

class AIServicesChart extends StatelessWidget {
  const AIServicesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Services Usage', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double chartSize = constraints.maxWidth.isFinite ? constraints.maxWidth : 200;
                return PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: (chartSize * 0.12).clamp(10, 40),
                    sections: showingSections(chartSize),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildLegend(context),
      ],
    );
  }

  List<PieChartSectionData> showingSections(double chartSize) {
    final double radius = chartSize * 0.18;
    return [
      PieChartSectionData(color: const Color(0xFF3B82F6), value: 40, title: '40%', radius: radius, titleStyle: GoogleFonts.poppins(fontSize: chartSize < 200 ? 10 : 12, fontWeight: FontWeight.bold, color: Colors.white)),
      PieChartSectionData(color: const Color(0xFF10B981), value: 30, title: '30%', radius: radius, titleStyle: GoogleFonts.poppins(fontSize: chartSize < 200 ? 10 : 12, fontWeight: FontWeight.bold, color: Colors.white)),
      PieChartSectionData(color: const Color(0xFFF59E0B), value: 20, title: '20%', radius: radius, titleStyle: GoogleFonts.poppins(fontSize: chartSize < 200 ? 10 : 12, fontWeight: FontWeight.bold, color: Colors.white)),
      PieChartSectionData(color: const Color(0xFF8B5CF6), value: 10, title: '10%', radius: radius, titleStyle: GoogleFonts.poppins(fontSize: chartSize < 200 ? 10 : 12, fontWeight: FontWeight.bold, color: Colors.white)),
    ];
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 12, runSpacing: 8,
      children: [
        _buildLegendItem(const Color(0xFF3B82F6), 'Assistant', context),
        _buildLegendItem(const Color(0xFF10B981), 'Images', context),
        _buildLegendItem(const Color(0xFFF59E0B), 'Text AI', context),
        _buildLegendItem(const Color(0xFF8B5CF6), 'Other', context),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
      ],
    );
  }
}
