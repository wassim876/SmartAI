import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Sidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const Sidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? 260 : 80,
      color: const Color(0xFF1e1e3f),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 40,
                  color: Colors.white,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartAI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Navigation Items
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isActive: true,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'Users',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/users');
                  },
                ),
                _buildNavItem(
                  icon: Icons.smart_toy_outlined,
                  label: 'AI Services',
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat Logs',
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Transactions',
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.assessment_outlined,
                  label: 'Reports',
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // User Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/admin-avatar.png'),
                  radius: 20,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Administrator',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white54,
      ),
      title: isExpanded
          ? Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 14,
              ),
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      style: ListTileStyle.drawer,
    );
  }
}
