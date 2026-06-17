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
  static const _primary = Color(0xFF5B4FE8);
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
                              style: GoogleFonts.poppins(fontSize: 14)),
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
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
        ],
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
          color: Colors.grey[500],
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E))),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]))
          : null,
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E))),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: _primary,
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 60, color: Color(0xFFF3F4F6));
}
