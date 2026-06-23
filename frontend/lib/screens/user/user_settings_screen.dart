import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../user/profile_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  static const _primary = Color(0xFF6C63FF);

  Color _bg(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF0B0B0F) : const Color(0xFFF4F6FB);
  Color _t1(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? Colors.white : const Color(0xFF12112A);
  Color _t2(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFFA0A0B0) : const Color(0xFF7B7A8E);
  Color _bd(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF2A2A3E) : const Color(0xFFEAEAF4);
  Color _card(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF161622) : Colors.white;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _t1(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate('settings'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _t1(context),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(loc.translate('profile')),
          _buildSettingCard([
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              color: _primary,
              title: loc.translate('editProfile'),
              subtitle: user?.displayName ?? loc.translate('editProfile'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.translate('appSection')),
          _buildSettingCard([
            _buildToggleItem(
              icon: Icons.notifications_none_rounded,
              color: Colors.red,
              title: loc.translate('pushNotifications'),
              value: true,
              onChanged: (_) {},
            ),
            _buildDivider(),
            _buildToggleItem(
              icon: Icons.dark_mode_outlined,
              color: Colors.indigo,
              title: loc.translate('darkMode'),
              value: themeProvider.isDarkMode,
              onChanged: (v) => themeProvider.toggleTheme(v),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.translate('support')),
          _buildSettingCard([
            _buildSettingItem(
              icon: Icons.help_outline_rounded,
              color: Colors.purple,
              title: loc.translate('helpCenter'),
              onTap: () => Navigator.pushNamed(context, '/help'),
            ),
          ]),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext ctx) {
    final loc = AppLocalizations.of(context);
    return InkWell(
      onTap: () async {
        final authProvider = Provider.of<AuthProvider>(ctx, listen: false);
        final navigator = Navigator.of(ctx);
        await authProvider.signOut();
        if (mounted) {
          navigator.pushReplacementNamed('/');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _t2(context),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bd(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500, color: _t1(context))),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: _t2(context)))
          : null,
      trailing:
          Icon(Icons.chevron_right_rounded, color: _t2(context), size: 20),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500, color: _t1(context))),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: _primary,
        activeTrackColor: _primary.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 1, indent: 56, color: _bd(context));
}
