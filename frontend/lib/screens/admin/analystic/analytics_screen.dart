import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track platform performance and usage trends',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text('Last 30 days', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  _summaryCard('Page Views', '482,920', '+8.4%', Colors.blue),
                  _summaryCard('Avg. Session', '4m 32s', '+1.2%', Colors.green),
                  _summaryCard('Bounce Rate', '32.4%', '-3.1%', Colors.red, negative: true),
                  _summaryCard('New Signups', '1,284', '+22.6%', Colors.purple),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requests Over Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        days[value.toInt() % 7],
                                        style: const TextStyle(fontSize: 12),
                                      ),
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
                                    color: const Color(0xFF5A4FCF),
                                    width: 18,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Container(
                  height: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Traffic Sources',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.indigo,
                                value: 45,
                                title: '45%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.teal,
                                value: 30,
                                title: '30%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.amber,
                                value: 15,
                                title: '15%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.pink,
                                value: 10,
                                title: '10%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _legendItem(Colors.indigo, 'Direct', '45%'),
                      _legendItem(Colors.teal, 'Search', '30%'),
                      _legendItem(Colors.amber, 'Social', '15%'),
                      _legendItem(Colors.pink, 'Referral', '10%'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, String change, Color color, {bool negative = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[900]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                negative ? Icons.arrow_downward : Icons.arrow_upward,
                size: 12,
                color: negative ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 2),
              Text(
                change,
                style: TextStyle(
                  color: negative ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text('vs last month', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(percentage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
