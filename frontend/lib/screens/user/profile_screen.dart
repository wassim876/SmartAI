import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _primary = Color(0xFF5B4FE8);
  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: _primary), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Avatar + name
          const SizedBox(height: 10),
          Stack(alignment: Alignment.bottomRight, children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: _primary.withValues(alpha: 0.1),
              backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
              child: user?.avatarUrl == null
                  ? Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: _primary))
                  : null,
            ),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: _primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 14),
          Text(user?.name ?? 'User', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
          Text(user?.email ?? '', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 12),
          if (user?.isPremium ?? false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.workspace_premium_rounded, size: 15, color: Color(0xFFD97706)),
                const SizedBox(width: 5),
                Text('Premium Member', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFD97706))),
              ]),
            ),

          const SizedBox(height: 24),

          // Stats row
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _statItem('125', 'AI Chats'),
              _vDivider(),
              _statItem('48', 'Images'),
              _vDivider(),
              _statItem('32', 'Translations'),
            ]),
          ),

          const SizedBox(height: 20),

          // Usage
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Your Plan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF1A1A2E))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(user?.isPremium == true ? '⭐ Premium' : 'Free', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
                ),
              ]),
              const SizedBox(height: 16),
              _statBar('Messages', user?.dailyMessagesUsed ?? 0, user?.dailyMessagesLimit ?? 50, _primary),
              const SizedBox(height: 10),
              _statBar('Speech (min)', user?.monthlySpeechMinutesUsed ?? 0, user?.monthlySpeechMinutesLimit ?? 10, const Color(0xFF3B82F6)),
              const SizedBox(height: 10),
              _statBar('Translation (chars)', user?.translationCharsUsed ?? 0, user?.translationCharsLimit ?? 1000, const Color(0xFF10B981)),
            ]),
          ),

          const SizedBox(height: 20),

          // Settings
          _section([
            _tile(Icons.settings_outlined, 'Settings', const Color(0xFF6B7280), () {}),
            _tile(Icons.help_outline_rounded, 'Help & Support', const Color(0xFF6B7280), () {}),
            _tile(Icons.info_outline_rounded, 'About SmartAI', const Color(0xFF6B7280), () {}),
          ]),

          const SizedBox(height: 12),

          _section([
            _tile(Icons.logout_rounded, 'Logout', const Color(0xFFEF4444), () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              }
            }, isDestructive: true),
          ]),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _statItem(String val, String label) => Column(children: [
    Text(val, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
    Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
  ]);

  Widget _vDivider() => Container(height: 36, width: 1, color: const Color(0xFFE5E7EB));

  Widget _statBar(String label, int used, int limit, Color color) {
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
        Text('$used / $limit', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
        value: progress, minHeight: 7,
        backgroundColor: color.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation(color),
      )),
    ]);
  }

  Widget _section(List<Widget> tiles) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(children: tiles),
  );

  Widget _tile(IconData icon, String title, Color color, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF1A1A2E))),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 20),
    );
  }
}