import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

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
          child: ListView(children: [
            _buildActivityItem(context, icon: Icons.person_add_rounded, iconColor: const Color(0xFF3B82F6), title: 'New user registered', subtitle: 'Sarah Johnson joined', time: '2 min ago'),
            _buildActivityItem(context, icon: Icons.chat_bubble_rounded, iconColor: const Color(0xFF10B981), title: 'New conversation started', subtitle: 'User #1234 started a chat', time: '5 min ago'),
            _buildActivityItem(context, icon: Icons.payment_rounded, iconColor: const Color(0xFFF59E0B), title: 'Payment received', subtitle: '\$29.99 from Michael B.', time: '12 min ago'),
            _buildActivityItem(context, icon: Icons.warning_amber_rounded, iconColor: const Color(0xFFF97316), title: 'API rate limit warning', subtitle: '80% of quota used', time: '25 min ago'),
            _buildActivityItem(context, icon: Icons.system_update_rounded, iconColor: const Color(0xFF8B5CF6), title: 'System update completed', subtitle: 'Version 2.1.0 deployed', time: '1 hour ago'),
          ]),
        ),
      ],
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
              Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: D.t1(context))),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
            ]),
          ),
          Text(time, style: GoogleFonts.poppins(fontSize: 10, color: D.t3(context))),
        ]),
      ),
    );
  }
}
