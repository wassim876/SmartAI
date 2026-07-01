import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/supabase_config.dart';
import '../../../theme/dark_mode_helpers.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Stay up to date with platform activity', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('notifications')
                .stream(primaryKey: ['id'])
                .order('created_at', ascending: false),
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
                      Icon(Icons.notifications_none_rounded, size: 56, color: D.t3(context)),
                      const SizedBox(height: 16),
                      Text('No notifications yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: D.t1(context))),
                      const SizedBox(height: 8),
                      Text('Platform notifications will appear here', style: GoogleFonts.poppins(fontSize: 14, color: D.t2(context))),
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
                    for (int i = 0; i < docs.length; i++) ...[
                      _buildNotification(context, docs[i]),
                      if (i < docs.length - 1) Divider(height: 1, color: D.divider(context)),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(BuildContext context, Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? 'info';
    final title = data['title']?.toString() ?? 'Notification';
    final subtitle = data['body']?.toString() ?? '';
    final createdAt = DateTime.tryParse(data['created_at']?.toString() ?? '');
    final read = data['read'] ?? false;

    final (icon, color) = _getNotificationStyle(type);
    final timeStr = createdAt != null ? _formatTime(createdAt) : '';

    return Container(
      color: !read ? const Color(0xFF6C63FF).withValues(alpha: 0.04) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: D.t1(context)))),
                    if (!read) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: Text(subtitle, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(timeStr, style: GoogleFonts.poppins(color: D.t3(context), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _getNotificationStyle(String type) {
    switch (type) {
      case 'new_user':
        return (Icons.person_add_alt_rounded, const Color(0xFF3B82F6));
      case 'new_review':
        return (Icons.star_outline_rounded, const Color(0xFFF59E0B));
      case 'new_chat':
        return (Icons.chat_bubble_outline_rounded, const Color(0xFF10B981));
      case 'payment':
        return (Icons.attach_money_rounded, const Color(0xFF14B8A6));
      case 'image_analysis':
        return (Icons.image_outlined, const Color(0xFF8B5CF6));
      case 'speech':
        return (Icons.mic_none_outlined, const Color(0xFF14B8A6));
      case 'flagged':
        return (Icons.warning_amber_rounded, const Color(0xFFEF4444));
      case 'signup':
        return (Icons.person_add_alt_rounded, const Color(0xFF3B82F6));
      case 'login':
        return (Icons.login_rounded, const Color(0xFF10B981));
      default:
        return (Icons.notifications_none_rounded, const Color(0xFF6B7280));
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}
