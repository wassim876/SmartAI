import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/admin/dashboard';
    final userProvider = context.watch<UserProvider>();

    return Container(
      width: 260,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
        ),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
        ),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(6),
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
                child: Image.asset('assets/images/smartai.png', height: 36, width: 36, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SmartAI', style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                Text('Admin Panel', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, letterSpacing: 0.5)),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
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
            _buildUserProfile(context, userProvider),
            const SizedBox(height: 12),
          ]),
        ),
      ]),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5B4FE8)],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF1A1A2E),
                  radius: 18,
                  backgroundImage: userProvider.profileImageBytes != null ? MemoryImage(userProvider.profileImageBytes!) : null,
                  child: userProvider.profileImageBytes == null
                      ? Icon(Icons.person, color: Colors.white.withValues(alpha: 0.7), size: 18)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(userProvider.userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(userProvider.userRole, style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                ]),
              ),
              Icon(Icons.more_horiz_rounded, color: Colors.white.withValues(alpha: 0.3), size: 16),
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
            color: isActive ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : Colors.transparent,
            border: isActive ? Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.25)) : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.white.withValues(alpha: 0.04),
              onTap: () { if (!isActive) Navigator.pushReplacementNamed(context, route); },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
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
                      decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
