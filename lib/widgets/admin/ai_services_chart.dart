import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AIServicesChart extends StatelessWidget {
  const AIServicesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Services Usage',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Safety clamp to prevent 0 or infinite size crashes
                final double chartSize =
                    constraints.maxWidth.isFinite ? constraints.maxWidth : 200;
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
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> showingSections(double chartSize) {
    final double radius = chartSize * 0.18;
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 40,
        title: '40%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: chartSize < 200 ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 30,
        title: '30%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: chartSize < 200 ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 20,
        title: '20%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: chartSize < 200 ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 10,
        title: '10%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: chartSize < 200 ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildLegendItem(Colors.blue, 'Assistant'),
        _buildLegendItem(Colors.green, 'Images'),
        _buildLegendItem(Colors.orange, 'Text AI'),
        _buildLegendItem(Colors.purple, 'Other'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }
}
