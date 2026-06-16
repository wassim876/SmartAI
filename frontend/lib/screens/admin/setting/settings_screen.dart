import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _twoFactorAuth = true;
  bool _isLoggingOut = false;
  final AuthService _authService = AuthService();

  Future<void> _handleLogoutEverywhere() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out everywhere?'),
        content: const Text(
          'This will sign you out from all active sessions on every device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);

    await _authService.logout();

    if (!mounted) return;

    setState(() => _isLoggingOut = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your account and platform preferences',
            style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
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
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(Icons.person,
                          color: theme.colorScheme.onPrimary, size: 36),
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
                        Row(children: [
                          Expanded(child: fields[0]),
                          const SizedBox(width: 16),
                          Expanded(child: fields[1])
                        ]),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(child: fields[2]),
                          const SizedBox(width: 16),
                          Expanded(child: fields[3])
                        ]),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      fields[0],
                      const SizedBox(height: 16),
                      fields[1],
                      const SizedBox(height: 16),
                      fields[2],
                      const SizedBox(height: 16),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Change Password',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Update your account password',
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12)),
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
              themeProvider.isDarkMode,
              (v) => context.read<ThemeProvider>().toggleTheme(v),
            ),
          ),
          const SizedBox(height: 20),

          // Danger Zone
          _sectionCard(
            title: 'Danger Zone',
            titleColor: Colors.red,
            child: LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              return Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Log out of all devices',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Sign out from all active sessions',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12)),
                    ],
                  ),
                  SizedBox(
                    width: isNarrow ? double.infinity : null,
                    child: OutlinedButton(
                      onPressed: _isLoggingOut ? null : _handleLogoutEverywhere,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: _isLoggingOut
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Text('Log out everywhere'),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required String title, required Widget child, Color? titleColor}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.light ? 0.05 : 0.4),
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
              color: titleColor ?? theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _textField(String label, String value, {bool enabled = true}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            filled: true,
            fillColor: enabled
                ? theme.inputDecorationTheme.fillColor
                : theme.disabledColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Switch(
            value: value,
            activeColor: theme.colorScheme.primary,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
