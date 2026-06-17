import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  static const _primary = Color(0xFF6C63FF);
  static const _bg = Color(0xFFF4F6FB);
  static const _text1 = Color(0xFF12112A);
  static const _text2 = Color(0xFF7B7A8E);
  static const _border = Color(0xFFEAEAF4);

  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // StatefulBuilder allows the modal UI to re-render instantly
        // when a user selects a new language checkmark.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ListView(
                shrinkWrap: true,
                children: ['English', 'French', 'Spanish', 'Arabic', 'German']
                    .map((lang) => ListTile(
                          title: Text(lang,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: _text1)),
                          trailing: _selectedLanguage == lang
                              ? const Icon(Icons.check_rounded, color: _primary)
                              : null,
                          onTap: () {
                            // Update parent state
                            setState(() => _selectedLanguage = lang);
                            // Update local modal state for the instant visual checkmark change
                            setModalState(() {});

                            // Give the user a brief visual confirmation before closing
                            Future.delayed(const Duration(milliseconds: 150),
                                () {
                              if (context.mounted) Navigator.pop(context);
                            });
                          },
                        ))
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _text1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _text1,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingCard([
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              color: Colors.blue,
              title: 'Profile Information',
              subtitle: user?.email ?? 'Update your name and email',
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.lock_outline_rounded,
              color: Colors.orange,
              title: 'Security',
              subtitle: 'Change password and 2FA',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildSettingCard([
            _buildToggleItem(
              icon: Icons.notifications_none_rounded,
              color: Colors.red,
              title: 'Push Notifications',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            _buildDivider(),
            _buildToggleItem(
              icon: Icons.dark_mode_outlined,
              color: Colors.indigo,
              title: 'Dark Mode',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.language_rounded,
              color: Colors.teal,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: _showLanguagePicker,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSettingCard([
            _buildSettingItem(
              icon: Icons.help_outline_rounded,
              color: Colors.purple,
              title: 'Help Center',
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.info_outline_rounded,
              color: Colors.grey,
              title: 'About SmartAI',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await context.read<AuthProvider>().logout();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: Color(0xFFEF4444), size: 20),
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
          color: _text2,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
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
              fontSize: 14, fontWeight: FontWeight.w500, color: _text1)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: _text2))
          : null,
      trailing:
          const Icon(Icons.chevron_right_rounded, color: _text2, size: 20),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // Replaced SwitchListTile with standard ListTile + trailing Switch
    // to maintain explicit content sizing control inside our custom card container.
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
              fontSize: 14, fontWeight: FontWeight.w500, color: _text1)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: _primary,
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 56, color: _border);
}
