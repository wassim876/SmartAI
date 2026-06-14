import 'package:flutter/material.dart';

class ChatLogsScreen extends StatelessWidget {
  const ChatLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
          const SizedBox(height: 24),

          // Logs Table
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
                // Search & Filter Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search conversations by user or keyword...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text('Filter', style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Table Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('USER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 2, child: Text('SERVICE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 4, child: Text('LAST MESSAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 1, child: Text('ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                    ],
                  ),
                ),
                const Divider(height: 1),

                _buildLogRow('Sarah Johnson', 'Chat Assistant', 'Can you summarize this report for me?', 'Jun 15, 2024', 'Completed'),
                _buildLogRow('Michael Brown', 'Image Analysis', 'Detected 3 objects in uploaded photo', 'Jun 15, 2024', 'Completed'),
                _buildLogRow('Emily Davis', 'Translation', 'Translate this document to French', 'Jun 14, 2024', 'Flagged'),
                _buildLogRow('David Wilson', 'Speech to Text', 'Transcribed 12 minute audio file', 'Jun 14, 2024', 'Completed'),
                _buildLogRow('Jessica Miller', 'Chat Assistant', 'What is the weather forecast today?', 'Jun 13, 2024', 'Completed'),
                _buildLogRow('Daniel Lee', 'Text to Speech', 'Generated voiceover for marketing video', 'Jun 13, 2024', 'Processing'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogRow(String user, String service, String message, String date, String status) {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Flagged':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(user, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(service, style: TextStyle(color: Colors.grey[600]))),
          Expanded(
            flex: 4,
            child: Text(
              message,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(flex: 2, child: Text(date, style: TextStyle(color: Colors.grey[600]))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(Icons.visibility, size: 18, color: Colors.grey),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
