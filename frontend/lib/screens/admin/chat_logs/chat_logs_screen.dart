import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/supabase_config.dart';
import '../../../theme/dark_mode_helpers.dart';

class ChatLogsScreen extends StatelessWidget {
  const ChatLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chat Logs', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('Review conversations between users and AI services', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14), overflow: TextOverflow.ellipsis,),
          const SizedBox(height: 24),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('chat_messages')
                .stream(primaryKey: ['id'])
                .order('created_at', ascending: false)
                .limit(200),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data ?? [];

              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: D.card(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: D.bd(context)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 56, color: D.t3(context)),
                      const SizedBox(height: 16),
                      Text('No chat logs yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: D.t1(context))),
                      const SizedBox(height: 8),
                      Text('User conversations will appear here', style: GoogleFonts.poppins(fontSize: 14, color: D.t2(context))),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: D.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: D.bd(context)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: D.inputFill(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: D.bd(context)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: D.t3(context), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('${docs.length} conversations', style: GoogleFonts.poppins(fontSize: 13, color: D.t2(context))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: D.divider(context)),
                    LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 650) {
                        return _buildTable(context, docs);
                      } else {
                        return _buildCardList(context, docs);
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

  Widget _buildTable(BuildContext context, List<Map<String, dynamic>> docs) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: _hCell(context, 'USER')),
              Expanded(flex: 2, child: _hCell(context, 'MODEL')),
              Expanded(flex: 4, child: _hCell(context, 'MESSAGE')),
              Expanded(flex: 2, child: _hCell(context, 'DATE')),
              const SizedBox(width: 40),
            ],
          ),
        ),
        Divider(height: 1, color: D.divider(context)),
        ...docs.map((data) {
          final userId = data['user_id']?.toString() ?? 'Unknown';
          final model = data['model']?.toString() ?? 'AI';
          final message = data['message']?.toString() ?? '';
          final createdAt = DateTime.tryParse(data['created_at']?.toString() ?? '');
          final dateStr = createdAt != null ? DateFormat('MMM d, yyyy').format(createdAt) : '';
          return _buildTableRow(context, userId, model, message, dateStr);
        }),
      ],
    );
  }

  Widget _buildTableRow(BuildContext context, String user, String model, String message, String date) {
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
                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                      child: Text(
                        user.length >= 2 ? user.substring(0, 2).toUpperCase() : user.toUpperCase(),
                        style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(user, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: D.t1(context)), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(model, style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(message, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text(date, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 13)),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  icon: Icon(Icons.visibility_outlined, size: 18, color: D.t3(context)),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: D.divider(context)),
      ],
    );
  }

  Widget _buildCardList(BuildContext context, List<Map<String, dynamic>> docs) {
    return Column(
      children: docs.map((data) {
        final userId = data['user_id']?.toString() ?? 'Unknown';
        final model = data['model']?.toString() ?? 'AI';
        final message = data['message']?.toString() ?? '';
        final createdAt = DateTime.tryParse(data['created_at']?.toString() ?? '');
        final dateStr = createdAt != null ? DateFormat('MMM d, yyyy').format(createdAt) : '';

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                    child: Text(
                      userId.length >= 2 ? userId.substring(0, 2).toUpperCase() : userId.toUpperCase(),
                      style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(userId, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: D.t1(context)))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(model, style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(message, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(dateStr, style: GoogleFonts.poppins(color: D.t3(context), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: D.divider(context)),
          ],
        );
      }).toList(),
    );
  }

  Widget _hCell(BuildContext context, String text) => Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: D.t2(context), letterSpacing: 0.5));
}
