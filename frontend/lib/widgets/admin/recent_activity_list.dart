import 'package:flutter/material.dart';

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
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildActivityItem(
                icon: Icons.person_add,
                iconColor: Colors.blue,
                title: 'New user registered',
                subtitle: 'Sarah Johnson joined',
                time: '2 min ago',
              ),
              _buildActivityItem(
                icon: Icons.chat_bubble,
                iconColor: Colors.green,
                title: 'New conversation started',
                subtitle: 'User #1234 started a chat',
                time: '5 min ago',
              ),
              _buildActivityItem(
                icon: Icons.payment,
                iconColor: Colors.amber,
                title: 'Payment received',
                subtitle: '\$29.99 from Michael B.',
                time: '12 min ago',
              ),
              _buildActivityItem(
                icon: Icons.warning_amber,
                iconColor: Colors.orange,
                title: 'API rate limit warning',
                subtitle: '80% of quota used',
                time: '25 min ago',
              ),
              _buildActivityItem(
                icon: Icons.system_update,
                iconColor: Colors.purple,
                title: 'System update completed',
                subtitle: 'Version 2.1.0 deployed',
                time: '1 hour ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
