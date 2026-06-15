import 'package:flutter/material.dart';

class ChatLogsScreen extends StatelessWidget {
  const ChatLogsScreen({super.key});

  final _logs = const [
    (
      'Sarah Johnson',
      'Chat Assistant',
      'Can you summarize this report for me?',
      'Jun 15, 2024',
      'Completed'
    ),
    (
      'Michael Brown',
      'Image Analysis',
      'Detected 3 objects in uploaded photo',
      'Jun 15, 2024',
      'Completed'
    ),
    (
      'Emily Davis',
      'Translation',
      'Translate this document to French',
      'Jun 14, 2024',
      'Flagged'
    ),
    (
      'David Wilson',
      'Speech to Text',
      'Transcribed 12 minute audio file',
      'Jun 14, 2024',
      'Completed'
    ),
    (
      'Jessica Miller',
      'Chat Assistant',
      'What is the weather forecast today?',
      'Jun 13, 2024',
      'Completed'
    ),
    (
      'Daniel Lee',
      'Text to Speech',
      'Generated voiceover for marketing video',
      'Jun 13, 2024',
      'Processing'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Chat Logs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review conversations between users and AI services',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Container card
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
              children: [
                // Search & Filter Bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search conversations...',
                            hintStyle: TextStyle(
                                fontSize: 13, color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.grey, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.filter_list,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text('Filter',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Responsive: table on wide, cards on narrow
                LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth > 650) {
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

  // ── Wide screen: proper table ──────────────────────────────────────────────
  Widget _buildTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: _hCell('USER')),
              Expanded(flex: 2, child: _hCell('SERVICE')),
              Expanded(flex: 4, child: _hCell('LAST MESSAGE')),
              Expanded(flex: 2, child: _hCell('DATE')),
              Expanded(flex: 2, child: _hCell('STATUS')),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1),
        ..._logs.map((r) {
          final (user, service, message, date, status) = r;
          return _buildTableRow(user, service, message, date, status);
        }),
      ],
    );
  }

  Widget _buildTableRow(
      String user, String service, String message, String date, String status) {
    final (color, bg) = _statusColors(status);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(user,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13))),
              Expanded(
                  flex: 2,
                  child: Text(service,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13))),
              Expanded(
                flex: 4,
                child: Text(message,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ),
              Expanded(
                  flex: 2,
                  child: Text(date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13))),
              Expanded(
                flex: 2,
                child: _statusBadge(status, color, bg),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  icon: const Icon(Icons.visibility,
                      size: 18, color: Colors.grey),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  // ── Narrow screen: card list ───────────────────────────────────────────────
  Widget _buildCardList() {
    return Column(
      children: _logs.map((r) {
        final (user, service, message, date, status) = r;
        final (color, bg) = _statusColors(status);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar circle
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF5A4FCF).withValues(alpha: 0.12),
                    child: Text(
                      user[0],
                      style: const TextStyle(
                        color: Color(0xFF5A4FCF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + status badge on same line
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _statusBadge(status, color, bg),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Service tag
                        Text(
                          service,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Last message
                        Text(
                          message,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Date + view button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 11),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Icon(Icons.visibility_outlined,
                                      size: 14, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _hCell(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600]),
      );

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'Completed':
        return (Colors.green, Colors.green.withValues(alpha: 0.1));
      case 'Flagged':
        return (Colors.red, Colors.red.withValues(alpha: 0.1));
      default:
        return (Colors.orange, Colors.orange.withValues(alpha: 0.1));
    }
  }

  Widget _statusBadge(String status, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
