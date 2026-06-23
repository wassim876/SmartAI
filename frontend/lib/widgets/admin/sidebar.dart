import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class Sidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const Sidebar({super.key, required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/admin/dashboard';
    final userProvider = context.watch<UserProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isExpanded ? 260 : 72,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16162A),
          ],
        ),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
        ),
      ),
      child: Column(children: [
        Container(
          padding: EdgeInsets.fromLTRB(isExpanded ? 20 : 0, 24, isExpanded ? 20 : 0, 20),
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: EdgeInsets.all(isExpanded ? 6 : 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withValues(alpha: 0.15),
                    const Color(0xFF5B4FE8).withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/smartai.png', height: isExpanded ? 36 : 32, width: isExpanded ? 36 : 32, fit: BoxFit.cover),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SmartAI', style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                  Text('Admin Panel', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, letterSpacing: 0.5)),
                ]),
              ),
            ],
          ]),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 8),
                  child: Text('MENU', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.25), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                ),
              _buildNavItem(context: context, icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/admin/dashboard', currentRoute: currentRoute),
              _buildNavItem(context: context, icon: Icons.people_rounded, label: 'Users', route: '/admin/users', currentRoute: currentRoute),
              _buildNavItem(context: context, icon: Icons.smart_toy_rounded, label: 'AI Services', route: '/admin/ai-services', currentRoute: currentRoute),
              _buildNavItem(context: context, icon: Icons.analytics_rounded, label: 'Analytics', route: '/admin/analytics', currentRoute: currentRoute),
              _buildNavItem(context: context, icon: Icons.chat_bubble_rounded, label: 'Chat Logs', route: '/admin/chat-logs', currentRoute: currentRoute),
              _buildNavItem(context: context, icon: Icons.assessment_rounded, label: 'Reports', route: '/admin/reports', currentRoute: currentRoute),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 16, bottom: 8),
                  child: Text('OTHER', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.25), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                ),
              _buildNavItem(context: context, icon: Icons.notifications_rounded, label: 'Notifications', route: '/admin/notifications', currentRoute: currentRoute),
              _buildNavItem(context: context, icon: Icons.rate_review_rounded, label: 'Reviews', route: '/admin/reviews', currentRoute: currentRoute),
              _buildNavItem(context: context, icon: Icons.settings_rounded, label: 'Settings', route: '/admin/settings', currentRoute: currentRoute),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(children: [
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            const SizedBox(height: 8),
            _buildCollapseButton(),
            const SizedBox(height: 8),
            _buildUserProfile(context, userProvider),
            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCollapseButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_double_arrow_left_rounded : Icons.keyboard_double_arrow_right_rounded,
                  color: Colors.white.withValues(alpha: 0.35),
                  size: 18,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 8),
                  Text('Collapse', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, UserProvider userProvider) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pushNamed(context, '/admin/settings'),
          child: Container(
            padding: EdgeInsets.all(isExpanded ? 12 : 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF),
                      const Color(0xFF5B4FE8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF1A1A2E),
                  radius: isExpanded ? 18 : 16,
                  backgroundImage: userProvider.profileImageBytes != null ? MemoryImage(userProvider.profileImageBytes!) : null,
                  child: userProvider.profileImageBytes == null
                      ? Icon(Icons.person, color: Colors.white.withValues(alpha: 0.7), size: isExpanded ? 18 : 16)
                      : null,
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(userProvider.userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(userProvider.userRole, style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                  ]),
                ),
                Icon(Icons.more_horiz_rounded, color: Colors.white.withValues(alpha: 0.3), size: 16),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required BuildContext context, required IconData icon, required String label, required String route, required String currentRoute}) {
    final bool isActive = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive
                ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                : Colors.transparent,
            border: isActive
                ? Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.25))
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.white.withValues(alpha: 0.04),
              onTap: () { if (!isActive) Navigator.pushReplacementNamed(context, route); },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isExpanded ? 14 : 0, vertical: 10),
                child: isExpanded
                    ? Row(children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isActive
                                ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.04),
                          ),
                          child: Icon(icon, color: isActive ? const Color(0xFF9B93FF) : Colors.white.withValues(alpha: 0.4), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(label, style: GoogleFonts.poppins(
                            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          )),
                        ),
                        if (isActive)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ])
                    : Center(
                        child: Icon(icon, color: isActive ? const Color(0xFF9B93FF) : Colors.white.withValues(alpha: 0.4), size: 20),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
