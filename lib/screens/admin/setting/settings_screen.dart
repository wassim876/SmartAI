import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _twoFactorAuth = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your account and platform preferences',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Profile Section
          _sectionCard(
            title: 'Profile Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF5A4FCF),
                      child: Icon(Icons.person, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Change Photo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  final fields = [
                    _textField('Full Name', 'John Doe'),
                    _textField('Email Address', 'john.doe@smartai.com'),
                    _textField('Role', 'Administrator', enabled: false),
                    _textField('Phone Number', '+1 (555) 123-4567'),
                  ];
                  if (isWide) {
                    return Column(
                      children: [
                        Row(children: [Expanded(child: fields[0]), const SizedBox(width: 16), Expanded(child: fields[1])]),
                        const SizedBox(height: 16),
                        Row(children: [Expanded(child: fields[2]), const SizedBox(width: 16), Expanded(child: fields[3])]),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      fields[0], const SizedBox(height: 16),
                      fields[1], const SizedBox(height: 16),
                      fields[2], const SizedBox(height: 16),
                      fields[3],
                    ],
                  );
                }),
                const SizedBox(height: 20),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A4FCF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Notifications Section
          _sectionCard(
            title: 'Notification Preferences',
            child: Column(
              children: [
                _switchRow(
                  'Email Notifications',
                  'Receive updates and alerts via email',
                  _emailNotifications,
                  (v) => setState(() => _emailNotifications = v),
                ),
                const Divider(height: 32),
                _switchRow(
                  'Push Notifications',
                  'Receive real-time alerts on your device',
                  _pushNotifications,
                  (v) => setState(() => _pushNotifications = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security Section
          _sectionCard(
            title: 'Security',
            child: Column(
              children: [
                _switchRow(
                  'Two-Factor Authentication',
                  'Add an extra layer of security to your account',
                  _twoFactorAuth,
                  (v) => setState(() => _twoFactorAuth = v),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Update your account password', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Appearance
          _sectionCard(
            title: 'Appearance',
            child: _switchRow(
              'Dark Mode',
              'Switch the admin panel to a dark theme',
              _darkMode,
              (v) => setState(() => _darkMode = v),
            ),
          ),
          const SizedBox(height: 20),

          // Danger Zone
          _sectionCard(
            title: 'Danger Zone',
            titleColor: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Log out of all devices', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Sign out from all active sessions', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Log out everywhere'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, Color? titleColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _textField(String label, String value, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _switchRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Switch(
            value: value,
            activeColor: const Color(0xFF5A4FCF),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
