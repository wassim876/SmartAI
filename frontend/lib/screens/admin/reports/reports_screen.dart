import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
                    'Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generate and download platform reports',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A4FCF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Report Type Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _reportTypeCard(Icons.people_outline, Colors.blue, 'User Activity', 'User growth, engagement & retention'),
                  _reportTypeCard(Icons.attach_money, Colors.green, 'Revenue', 'Income, subscriptions & refunds'),
                  _reportTypeCard(Icons.smart_toy_outlined, Colors.purple, 'AI Usage', 'Service usage by type & volume'),
                  _reportTypeCard(Icons.security_outlined, Colors.orange, 'System Health', 'Uptime, errors & performance'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent Reports Table
          Container(
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Recent Reports',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                  ),
                ),
                const Divider(height: 1),

                // Table Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('REPORT NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 2, child: Text('TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 2, child: Text('GENERATED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 1, child: Text('FORMAT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 1, child: Text('ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                    ],
                  ),
                ),
                const Divider(height: 1),

                _buildReportRow('Monthly User Growth - May 2024', 'User Activity', 'Jun 1, 2024', 'PDF'),
                _buildReportRow('Revenue Summary - Q2 2024', 'Revenue', 'Jun 5, 2024', 'XLSX'),
                _buildReportRow('AI Services Usage - May 2024', 'AI Usage', 'Jun 2, 2024', 'CSV'),
                _buildReportRow('System Uptime Report - May 2024', 'System Health', 'Jun 1, 2024', 'PDF'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportTypeCard(IconData icon, Color color, String title, String description) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String name, String type, String date, String format) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(type, style: TextStyle(color: Colors.grey[600]))),
          Expanded(flex: 2, child: Text(date, style: TextStyle(color: Colors.grey[600]))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                format,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(Icons.download_outlined, size: 18, color: Colors.grey),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
