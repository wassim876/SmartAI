import 'package:flutter/material.dart';

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
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/admin/dashboard';

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/smartai.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: '/admin/dashboard',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.people_outline,
                  label: 'Users',
                  route: '/admin/users',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.smart_toy_outlined,
                  label: 'AI Services',
                  route: '/admin/ai-services',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  route: '/admin/analytics',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat Logs',
                  route: '/admin/chat-logs',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  label: 'Transactions',
                  route: '/admin/transactions',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.assessment_outlined,
                  label: 'Reports',
                  route: '/admin/reports',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  route: '/admin/notifications',
                  currentRoute: currentRoute,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  route: '/admin/settings',
                  currentRoute: currentRoute,
                ),
              ],
            ),
          ),

          // Sidebar collapse toggle
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Icon(
                  isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white54,
                ),
              ),
            ),
          ),

          // User Profile Section
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/admin/settings');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF5A4FCF),
                      radius: 20,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      const Expanded(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required String currentRoute,
  }) {
    final bool isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: isActive ? const Color(0xFF5A4FCF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (!isActive) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isActive ? Colors.white : Colors.white54,
                    size: 22,
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
