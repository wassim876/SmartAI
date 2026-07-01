import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';

class AIServicesChart extends StatelessWidget {
  const AIServicesChart({super.key, required this.breakdown});

  final List<dynamic> breakdown;

  static const List<Color> _colors = [
    Color(0xFF3B82F6), // Chat
    Color(0xFF10B981), // Images
    Color(0xFFF59E0B), // Speech
    Color(0xFF8B5CF6), // Translation
  ];

  Color _colorFor(int index) => _colors[index % _colors.length];

  int _countFor(dynamic item) {
    if (item is Map) return ((item['count'] ?? 0) as num).toInt();
    return 0;
  }

  String _labelFor(dynamic item, int index) {
    if (item is Map && item['label'] != null) return item['label'].toString();
    return 'Item ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final int total =
        breakdown.fold<int>(0, (sum, e) => sum + _countFor(e));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Services Usage', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
        const SizedBox(height: 10),
        if (total == 0)
          Expanded(
            child: Center(
              child: Text('No usage yet',
                  style: GoogleFonts.poppins(fontSize: 13, color: D.t3(context))),
            ),
          )
        else ...[
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double chartSize = constraints.maxWidth.isFinite ? constraints.maxWidth : 200;
                  return PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: (chartSize * 0.12).clamp(10, 40),
                      sections: _showingSections(chartSize, total),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildLegend(context),
        ],
      ],
    );
  }

  List<PieChartSectionData> _showingSections(double chartSize, int total) {
    final double radius = chartSize * 0.18;
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < breakdown.length; i++) {
      final count = _countFor(breakdown[i]);
      if (count == 0) continue;
      final pct = (count / total * 100).round();
      sections.add(PieChartSectionData(
        color: _colorFor(i),
        value: count.toDouble(),
        title: '$pct%',
        radius: radius,
        titleStyle: GoogleFonts.poppins(fontSize: chartSize < 200 ? 10 : 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    return sections;
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 12, runSpacing: 8,
      children: [
        for (int i = 0; i < breakdown.length; i++)
          _buildLegendItem(_colorFor(i), _labelFor(breakdown[i], i), context),
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
