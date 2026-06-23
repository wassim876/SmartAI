import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/photo_picker_service.dart';
import '../../../theme/dark_mode_helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _isLoggingOut = false;
  final PhotoPickerService _photoPicker = PhotoPickerService();

  Future<void> _handleLogoutEverywhere() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: D.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log out everywhere?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: D.t1(context))),
        content: Text('This will sign you out from all active sessions on every device.', style: GoogleFonts.poppins(color: D.t2(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: D.t2(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: Text('Log out', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isLoggingOut = true);
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();
    if (!mounted) return;
    setState(() => _isLoggingOut = false);
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _changeProfilePhoto() async {
    final userProvider = context.read<UserProvider>();

    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: D.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: D.t3(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Choose Photo', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: D.t1(context))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(icon: Icons.photo_library_rounded, label: 'Gallery', onTap: () => Navigator.pop(context, 'gallery')),
                  _buildPhotoOption(icon: Icons.delete_outline_rounded, label: 'Remove', onTap: () => Navigator.pop(context, 'remove'), color: const Color(0xFFEF4444)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (choice == null) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    if (choice == 'gallery') {
      final imageBytes = await _photoPicker.pickImageFromGallery();
      if (imageBytes != null && mounted) {
        userProvider.updateProfileImage(imageBytes);
        messenger.showSnackBar(SnackBar(
          content: Text('Profile photo updated successfully!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } else if (choice == 'remove') {
      userProvider.updateProfileImage(null);
      messenger.showSnackBar(SnackBar(
        content: Text('Profile photo removed!', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Widget _buildPhotoOption({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color ?? const Color(0xFF6C63FF)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: color ?? const Color(0xFF6C63FF))),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('Manage your account and platform preferences', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14)),
          const SizedBox(height: 24),

          _sectionCard(
            title: 'Profile Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [const Color(0xFF6C63FF), const Color(0xFF5B4FE8)]),
                            border: Border.all(color: D.bd(context), width: 3),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: D.card(context),
                            backgroundImage: userProvider.profileImageBytes != null ? MemoryImage(userProvider.profileImageBytes!) : null,
                            child: userProvider.profileImageBytes == null ? Icon(Icons.person_rounded, color: D.t2(context), size: 36) : null,
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
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: D.card(context), width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton.icon(
                        onPressed: _changeProfilePhoto,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: Text('Change Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: D.t1(context),
                          side: BorderSide(color: D.bd(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      _textField('Full Name', userProvider.userName, onChanged: (value) => context.read<UserProvider>().updateUserName(value)),
                      _textField('Email Address', authProvider.currentUser?.email ?? 'Not available', enabled: false),
                      _textField('Role', userProvider.userRole, enabled: false),
                    ];
                    if (isWide) {
                      return Column(children: [
                        Row(children: [Expanded(child: fields[0]), const SizedBox(width: 16), Expanded(child: fields[1])]),
                        const SizedBox(height: 16),
                        fields[2],
                      ]);
                    }
                    return Column(children: [fields[0], const SizedBox(height: 16), fields[1], const SizedBox(height: 16), fields[2]]);
                  },
                ),
                const SizedBox(height: 20),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Profile updated successfully!', style: GoogleFonts.poppins()),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Save Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _sectionCard(
            title: 'Notification Preferences',
            child: Column(
              children: [
                _switchRow('Email Notifications', 'Receive updates and alerts via email', _emailNotifications, (v) => setState(() => _emailNotifications = v)),
                Divider(color: D.divider(context), height: 32),
                _switchRow('Push Notifications', 'Receive real-time alerts on your device', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _sectionCard(
            title: 'Appearance',
            child: _switchRow('Dark Mode', 'Switch the admin panel to a dark theme', themeProvider.isDarkMode, (v) => context.read<ThemeProvider>().toggleTheme(v)),
          ),
          const SizedBox(height: 20),

          _sectionCard(
            title: 'Danger Zone',
            titleColor: const Color(0xFFEF4444),
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
                        Text('Log out of all devices', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: D.t1(context))),
                        const SizedBox(height: 4),
                        Text('Sign out from all active sessions', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12)),
                      ],
                    ),
                    SizedBox(
                      width: isNarrow ? double.infinity : null,
                      child: OutlinedButton(
                        onPressed: _isLoggingOut ? null : _handleLogoutEverywhere,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: _isLoggingOut
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                            : Text('Log out everywhere', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

  Widget _sectionCard({required String title, required Widget child, Color? titleColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: D.bd(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: titleColor ?? D.t1(context))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _textField(String label, String value, {bool enabled = true, ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: D.t2(context))),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          controller: enabled ? null : TextEditingController(text: value),
          onChanged: onChanged,
          style: GoogleFonts.poppins(color: D.t1(context)),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: D.bd(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: D.bd(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: D.bd(context)),
            ),
            filled: true,
            fillColor: enabled ? D.inputFill(context) : D.hover(context),
            hintStyle: GoogleFonts.poppins(color: D.t3(context)),
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
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: D.t1(context))),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12)),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Switch(
            value: value,
            activeThumbColor: const Color(0xFF6C63FF),
            activeTrackColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
