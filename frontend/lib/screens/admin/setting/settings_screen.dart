// lib/screens/admin/setting/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/photo_picker_service.dart';

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
  final PhotoPickerService _photoPicker = PhotoPickerService();

  Future<void> _handleLogoutEverywhere() async {
    final authProvider = context.read<AuthProvider>();
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

    // Use AuthProvider to clear global state and notify listeners
    await authProvider.logout();

    if (!mounted) return;

    setState(() => _isLoggingOut = false);

    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _changeProfilePhoto() async {
    final userProvider = context.read<UserProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => Navigator.pop(context, 'gallery'),
                  ),
                  _buildPhotoOption(
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context, 'remove');
                    },
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (choice == null) return;

    if (choice == 'gallery') {
      final imageBytes = await _photoPicker.pickImageFromGallery();
      if (imageBytes != null && mounted) {
        userProvider.updateProfileImage(imageBytes);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (choice == 'remove') {
      userProvider.updateProfileImage(null);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Profile photo removed!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? (isDark ? Colors.white : theme.primaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? (isDark ? Colors.white70 : theme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
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
                    // Profile Image with edit button
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: theme.colorScheme.primary,
                            backgroundImage: userProvider.profileImageBytes !=
                                    null
                                ? MemoryImage(userProvider.profileImageBytes!)
                                : null,
                            child: userProvider.profileImageBytes == null
                                ? Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 36,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: _changeProfilePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: _changeProfilePhoto,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : null,
                          side: BorderSide(
                            color: isDark ? Colors.white54 : theme.primaryColor,
                          ),
                        ),
                        child: Text(
                          'Change Photo',
                          style: TextStyle(
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final fields = [
                      _textField(
                        'Full Name',
                        userProvider.userName,
                        onChanged: (value) =>
                            context.read<UserProvider>().updateUserName(value),
                      ),
                      _textField(
                        'Email Address',
                        authProvider.currentUser?.email ?? 'Not available',
                        enabled: false,
                      ),
                      _textField(
                        'Role',
                        userProvider.userRole,
                        enabled: false,
                      ),
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
                          // Role field takes the full width of the second row
                          fields[2],
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
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your account password',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : null,
                          side: BorderSide(
                            color: isDark ? Colors.white54 : theme.primaryColor,
                          ),
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
                            color: isDark ? Colors.white : null,
                          ),
                        ),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
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
                        Text(
                          'Log out of all devices',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign out from all active sessions',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: isNarrow ? double.infinity : null,
                      child: OutlinedButton(
                        onPressed:
                            _isLoggingOut ? null : _handleLogoutEverywhere,
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161622) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.05),
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
              color: titleColor ??
                  (isDark ? Colors.white : theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _textField(
    String label,
    String value, {
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: enabled ? null : TextEditingController(text: value),
          onChanged: onChanged,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? theme.primaryColor : theme.primaryColor,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            filled: true,
            fillColor: isDark
                ? (enabled ? const Color(0xFF1C1C2D) : const Color(0xFF2A2A3E))
                : (enabled ? Colors.grey.shade50 : Colors.grey.shade100),
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isDark ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? Colors.white54
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Switch(
            value: value,
            activeColor: theme.colorScheme.primary,
            activeTrackColor:
                isDark ? theme.primaryColor.withValues(alpha: 0.5) : null,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
