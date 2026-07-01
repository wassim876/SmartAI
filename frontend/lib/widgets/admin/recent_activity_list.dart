import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key, required this.items});

  final List<dynamic> items;

  ({IconData icon, Color color, String title}) _mapAction(String action) {
    switch (action) {
      case 'signup':
        return (icon: Icons.person_add_rounded, color: const Color(0xFF3B82F6), title: 'New user registered');
      case 'login':
      case 'google_login':
      case 'github_login':
        return (icon: Icons.login_rounded, color: const Color(0xFF10B981), title: 'User signed in');
      default:
        return (icon: Icons.bolt_rounded, color: const Color(0xFF8B5CF6), title: action);
    }
  }

  String _relativeTime(String? createdAt) {
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hr${h == 1 ? '' : 's'} ago';
    }
    final d = diff.inDays;
    return '$d day${d == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text('View All', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C63FF), fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text('No recent activity',
                      style: GoogleFonts.poppins(fontSize: 13, color: D.t3(context))),
                )
              : ListView(
                  children: [
                    for (final raw in items) _buildItem(context, raw),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, dynamic raw) {
    final map = raw is Map ? raw : const {};
    final action = (map['action'] ?? '').toString();
    final mapped = _mapAction(action);
    final displayName = map['display_name'];
    final email = map['email'];
    final subtitle = (displayName ?? email ?? 'Unknown user').toString();
    final time = _relativeTime(map['created_at']?.toString());

    return _buildActivityItem(
      context,
      icon: mapped.icon,
      iconColor: mapped.color,
      title: mapped.title,
      subtitle: subtitle,
      time: time,
    );
  }

  Widget _buildActivityItem(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String subtitle, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: D.hover(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: D.t1(context))),
              const SizedBox(height: 2),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
            ]),
          ),
          const SizedBox(width: 8),
          Text(time, style: GoogleFonts.poppins(fontSize: 10, color: D.t3(context))),
        ]),
      ),
    );
  }
}
