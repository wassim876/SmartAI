import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIX 1: Header — wrap title in Expanded, stack vertically on narrow screens
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Generate', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A4FCF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // FIX 2: Report type cards — always 2 columns on mobile, fix aspect ratio
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
              // FIX 3: Larger aspect ratio so content fits without overflow
              final aspectRatio = constraints.maxWidth > 700 ? 1.3 : 1.1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: aspectRatio,
                children: [
                  _reportTypeCard(Icons.people_outline, Colors.blue,
                      'User Activity', 'User growth, engagement & retention'),
                  _reportTypeCard(Icons.attach_money, Colors.green, 'Revenue',
                      'Income, subscriptions & refunds'),
                  _reportTypeCard(Icons.smart_toy_outlined, Colors.purple,
                      'AI Usage', 'Service usage by type & volume'),
                  _reportTypeCard(Icons.security_outlined, Colors.orange,
                      'System Health', 'Uptime, errors & performance'),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Recent Reports — FIX 4: use a card-list layout on mobile instead of a table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'Recent Reports',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                const Divider(height: 1),
                LayoutBuilder(builder: (context, constraints) {
                  // Wide: use table layout; narrow: use card list
                  if (constraints.maxWidth > 600) {
                    return _buildTable();
                  } else {
                    return _buildCardList();
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Table layout for wide screens
  Widget _buildTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: _headerCell('REPORT NAME')),
              Expanded(flex: 2, child: _headerCell('TYPE')),
              Expanded(flex: 2, child: _headerCell('GENERATED')),
              Expanded(flex: 1, child: _headerCell('FORMAT')),
              Expanded(flex: 1, child: _headerCell('ACTIONS')),
            ],
          ),
        ),
        const Divider(height: 1),
        _buildReportRow('Monthly User Growth - May 2024', 'User Activity',
            'Jun 1, 2024', 'PDF'),
        _buildReportRow(
            'Revenue Summary - Q2 2024', 'Revenue', 'Jun 5, 2024', 'XLSX'),
        _buildReportRow(
            'AI Services Usage - May 2024', 'AI Usage', 'Jun 2, 2024', 'CSV'),
        _buildReportRow('System Uptime Report - May 2024', 'System Health',
            'Jun 1, 2024', 'PDF'),
      ],
    );
  }

  // FIX 5: Card-based list for mobile — no cramped table columns
  Widget _buildCardList() {
    final reports = [
      ('Monthly User Growth - May 2024', 'User Activity', 'Jun 1, 2024', 'PDF'),
      ('Revenue Summary - Q2 2024', 'Revenue', 'Jun 5, 2024', 'XLSX'),
      ('AI Services Usage - May 2024', 'AI Usage', 'Jun 2, 2024', 'CSV'),
      (
        'System Uptime Report - May 2024',
        'System Health',
        'Jun 1, 2024',
        'PDF'
      ),
    ];

    return Column(
      children: reports.map((r) {
        final (name, type, date, format) = r;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(type,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                            Text(' · ',
                                style: TextStyle(color: Colors.grey[400])),
                            Text(date,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      format,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.download_outlined,
                        size: 18, color: Colors.grey),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }

  Widget _headerCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _reportTypeCard(
      IconData icon, Color color, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // FIX 6: don't force-expand column
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          // FIX 7: clamp to 2 lines so it never overflows the card
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String name, String type, String date, String format) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(type,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(date,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                format,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.download_outlined,
                  size: 18, color: Colors.grey),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
