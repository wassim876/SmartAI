import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stay up to date with platform activity',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Mark all as read'),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
                _notificationRow(
                  icon: Icons.person_add_alt,
                  color: Colors.blue,
                  title: 'New user registered',
                  subtitle: 'Sarah Johnson just created an account',
                  time: '2 minutes ago',
                  unread: true,
                ),
                const Divider(height: 1),
                _notificationRow(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.green,
                  title: 'AI conversation created',
                  subtitle: 'A new chat session was started',
                  time: '5 minutes ago',
                  unread: true,
                ),
                const Divider(height: 1),
                _notificationRow(
                  icon: Icons.attach_money,
                  color: Colors.amber,
                  title: 'Payment received',
                  subtitle: 'Subscription payment of \$49.00 received',
                  time: '15 minutes ago',
                  unread: false,
                ),
                const Divider(height: 1),
                _notificationRow(
                  icon: Icons.image_outlined,
                  color: Colors.purple,
                  title: 'Image analysis completed',
                  subtitle: 'Batch job finished processing 24 images',
                  time: '25 minutes ago',
                  unread: false,
                ),
                const Divider(height: 1),
                _notificationRow(
                  icon: Icons.mic_none_outlined,
                  color: Colors.teal,
                  title: 'Speech to text used',
                  subtitle: 'Audio transcription request completed',
                  time: '35 minutes ago',
                  unread: false,
                ),
                const Divider(height: 1),
                _notificationRow(
                  icon: Icons.warning_amber_outlined,
                  color: Colors.red,
                  title: 'Flagged conversation',
                  subtitle: 'A chat log was flagged for review',
                  time: '1 hour ago',
                  unread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required bool unread,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {},
        child: Container(
          color: unread
              ? const Color(0xFF5A4FCF).withOpacity(0.04)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(time,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              if (unread) ...[
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5A4FCF),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
