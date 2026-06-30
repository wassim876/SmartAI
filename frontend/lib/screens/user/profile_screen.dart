import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/photo_picker_service.dart';
import '../../models/user_model.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _primary = Color(0xFF6C63FF);

  Color _bg(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF0B0B0F) : const Color(0xFFF4F6FB);
  Color _t1(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? Colors.white : const Color(0xFF12112A);
  Color _t2(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFFA0A0B0) : const Color(0xFF7B7A8E);
  Color _bd(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF2A2A3E) : const Color(0xFFEAEAF4);
  Color _card(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF161622) : Colors.white;

  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isUploading = false;
  bool _isSaving = false;
  final PhotoPickerService _photoPicker = PhotoPickerService();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(AppLocalizations loc) async {
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();
    final hasPhoto = authProvider.currentUser?.photoURL?.isNotEmpty == true;

    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                loc.translate('changeProfilePhoto'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _t1(ctx),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: _primary),
                ),
                title: Text(loc.translate('chooseFromGallery'),
                    style: GoogleFonts.poppins(fontSize: 14, color: _t1(ctx))),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              if (hasPhoto)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: Text(loc.translate('removePhoto'),
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.red)),
                  onTap: () => Navigator.pop(ctx, 'remove'),
                ),
            ],
          ),
        ),
      ),
    );

    if (result == null) return;

    if (result == 'remove') {
      try {
        setState(() => _isUploading = true);
        await authProvider.updateProfile(
          displayName: _nameController.text.trim(),
          clearPhoto: true,
        );
        if (mounted) {
          messenger.showSnackBar(SnackBar(
            content: Text(loc.translate('profileRemoved')),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
      return;
    }

    // Pick image using the same service as admin settings
    final imageBytes = await _photoPicker.pickImageFromGallery();
    if (imageBytes == null || !mounted) return;

    try {
      setState(() => _isUploading = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('$uid.jpg');

      await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();

      await authProvider.updateProfile(
        displayName: _nameController.text.trim(),
        photoURL: downloadUrl,
      );

      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text(loc.translate('profileUpdated')),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveName(AppLocalizations loc) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isSaving = true);
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateProfile(
        displayName: newName,
        photoURL: authProvider.currentUser?.photoURL,
      );
      await authProvider.updateUserProfile({'displayName': newName});

      if (mounted) {
        setState(() => _isEditingName = false);
        messenger.showSnackBar(SnackBar(
          content: Text(loc.translate('nameUpdated')),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('${loc.translate('failedToSubmit')}: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context); // ✅ Get localization
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: _t1(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate('profile'), // ✅
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _t1(context),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          _buildProfileHeader(user, loc),
          const SizedBox(height: 28),
          _buildSectionHeader(loc.translate('account')), // ✅
          _buildAccountCard(user, loc),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.translate('stats')), // ✅
          _buildStatsCard(authProvider, loc),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.translate('preferences')), // ✅
          _buildPreferencesCard(themeProvider, loc),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.translate('security')), // ✅
          _buildSecurityCard(loc),
          const SizedBox(height: 32),
          _buildLogoutButton(context, loc),
          const SizedBox(height: 12),
          _buildDeleteAccountButton(context, loc),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9F7AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : () => _pickAndUploadImage(loc),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _card(context), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                        ? Text(
                            (user?.displayName != null && user!.displayName.isNotEmpty)
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: _card(context),
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _card(context),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: _isUploading
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _primary,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: _primary,
                          ),
                  ),
                ),
              ],
            ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.displayName ?? 'User',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _card(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          if (user?.isPremium == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    loc.translate('premiumMember'), // ✅
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _card(context),
                    ),
                  ),
                ],
              ),
            ),
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
          color: _t2(context),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Material(
      color: _card(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
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
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final itemColor = isDestructive ? Colors.red : color;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: itemColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: itemColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : _t1(context),
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: _t2(context)))
          : null,
      trailing: Icon(Icons.chevron_right_rounded, color: _t2(context), size: 20),
    );
  }

  Widget _buildAccountCard(UserModel? user, AppLocalizations loc) {
    return _buildSettingCard([
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: _primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('displayName'), // ✅
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: _t2(context))),
                  const SizedBox(height: 2),
                  _isEditingName
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _t1(context)),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: _bd(context)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: _primary),
                                  ),
                                ),
                                autofocus: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _isSaving ? null : () => _saveName(loc),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: () => setState(() => _isEditingName = true),
                          child: Text(
                            user?.displayName ?? 'User',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _t1(context),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            if (!_isEditingName)
              GestureDetector(
                onTap: () => setState(() => _isEditingName = true),
                child: Icon(Icons.edit_rounded, size: 16, color: _primary),
              ),
          ],
        ),
      ),
      Divider(height: 1, indent: 56, color: _bd(context)),
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.email_outlined,
              color: Colors.orange, size: 20),
        ),
        title: Text(loc.translate('email'), // ✅
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w500, color: _t1(context))),
        subtitle: Text(user?.email ?? '',
            style: GoogleFonts.poppins(fontSize: 12, color: _t2(context))),
      ),
    ]);
  }

  Widget _buildStatsCard(AuthProvider authProvider, AppLocalizations loc) {
    final stats = [
      (authProvider.chatHistory.length.toString(), loc.translate('aiChats'), // ✅
          Icons.chat_bubble_rounded, const Color(0xFF6C63FF)),
      (authProvider.imageAnalyses.length.toString(), loc.translate('imagesAnalyzed'), // ✅
          Icons.image_rounded, const Color(0xFF3B82F6)),
      (authProvider.speechTranscriptions.length.toString(), loc.translate('voiceNotes'), // ✅
          Icons.mic_rounded, const Color(0xFF8B5CF6)),
    ];

    return _buildSettingCard([
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: stats.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0, right: i < stats.length - 1 ? 8 : 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: s.$4.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: s.$4.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: s.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(s.$3, color: s.$4, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(s.$1,
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _t1(context),
                              letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text(s.$2,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _t2(context),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _buildPreferencesCard(ThemeProvider themeProvider, AppLocalizations loc) {
    return _buildSettingCard([
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.dark_mode_outlined,
              color: Colors.indigo, size: 20),
        ),
        title: Text(loc.translate('darkMode'), // ✅
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w500, color: _t1(context))),
        trailing: Switch.adaptive(
          value: themeProvider.isDarkMode,
          onChanged: (v) => themeProvider.toggleTheme(v),
          activeThumbColor: _primary,
          activeTrackColor: _primary.withValues(alpha: 0.4),
        ),
      ),
    ]);
  }

  Widget _buildSecurityCard(AppLocalizations loc) {
    return _buildSettingCard([
      _buildSettingItem(
        icon: Icons.lock_outline_rounded,
        color: Colors.orange,
        title: loc.translate('changePassword'), // ✅
        subtitle: loc.translate('changePasswordDesc'), // ✅
        onTap: () {},
      ),
      Divider(height: 1, indent: 56, color: _bd(context)),
      _buildSettingItem(
        icon: Icons.shield_outlined,
        color: Colors.blue,
        title: loc.translate('twoFactor'), // ✅
        subtitle: loc.translate('twoFactorDesc'), // ✅
        onTap: () {},
      ),
    ]);
  }

  Widget _buildLogoutButton(BuildContext ctx, AppLocalizations loc) {
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
            const Icon(Icons.logout_rounded,
                color: Color(0xFFEF4444), size: 20),
            const SizedBox(width: 10),
            Text(
              loc.translate('signOut'), // ✅
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

  Widget _buildDeleteAccountButton(BuildContext ctx, AppLocalizations loc) {
    return TextButton(
      onPressed: () {},
      child: Text(
        loc.translate('deleteAccount'), // ✅
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}