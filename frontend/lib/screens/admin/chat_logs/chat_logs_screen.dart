import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatLogsScreen extends StatelessWidget {
  const ChatLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat_messages')
                .orderBy('createdAt', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No chat logs yet',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800])),
                      const SizedBox(height: 8),
                      Text('User conversations will appear here',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              return Container(
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
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search,
                                      color: Colors.grey[400], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${docs.length} conversations',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey[500]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 650) {
                        return _buildTable(docs);
                      } else {
                        return _buildCardList(docs);
                      }
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<QueryDocumentSnapshot> docs) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: _hCell('USER')),
              Expanded(flex: 2, child: _hCell('MODEL')),
              Expanded(flex: 4, child: _hCell('MESSAGE')),
              Expanded(flex: 2, child: _hCell('DATE')),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1),
        ...docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final userId = data['userId'] ?? 'Unknown';
          final model = data['model'] ?? 'AI';
          final message = data['message'] ?? '';
          final createdAt = data['createdAt'] as Timestamp?;
          final dateStr = createdAt != null
              ? DateFormat('MMM d, yyyy').format(createdAt.toDate())
              : '';
          return _buildTableRow(userId, model, message, dateStr);
        }),
      ],
    );
  }

  Widget _buildTableRow(String user, String model, String message, String date) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF5A4FCF).withValues(alpha: 0.1),
                      child: Text(
                        user.length >= 2 ? user.substring(0, 2).toUpperCase() : user.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF5A4FCF),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(user,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A4FCF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(model,
                      style: const TextStyle(
                          color: Color(0xFF5A4FCF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(message,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text(date,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  icon: const Icon(Icons.visibility, size: 18, color: Colors.grey),
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

  Widget _buildCardList(List<QueryDocumentSnapshot> docs) {
    return Column(
      children: docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] ?? 'Unknown';
        final model = data['model'] ?? 'AI';
        final message = data['message'] ?? '';
        final createdAt = data['createdAt'] as Timestamp?;
        final dateStr = createdAt != null
            ? DateFormat('MMM d, yyyy').format(createdAt.toDate())
            : '';

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF5A4FCF).withValues(alpha: 0.12),
                    child: Text(
                      userId.length >= 2 ? userId.substring(0, 2).toUpperCase() : userId.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF5A4FCF),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(userId,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5A4FCF).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(model,
                                  style: const TextStyle(
                                      color: Color(0xFF5A4FCF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(message,
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(dateStr,
                            style: TextStyle(color: Colors.grey[400], fontSize: 11)),
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

  Widget _hCell(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600]),
      );
}
