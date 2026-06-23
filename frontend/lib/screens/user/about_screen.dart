import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/dark_mode_helpers.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 840;

    return Scaffold(
      backgroundColor: D.bg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: D.t1(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About SmartAI',
          style: GoogleFonts.poppins(
            color: D.t1(context),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildDescriptionCard(context),
                const SizedBox(height: 40),
                _buildSupportSection(context),
                const SizedBox(height: 40),
                Text(
                  '© 2026 SmartAI Inc.',
                  style: GoogleFonts.poppins(
                    color: D.t2(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: D.card(context),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/smartai.png',
            width: 80,
            height: 80,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'SmartAI',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: D.t1(context),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'v1.0.0',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6C63FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: D.bd(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Mission',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'SmartAI is a next-generation multimodal platform designed to bring the power of artificial intelligence to your fingertips. From advanced chat capabilities to image analysis, we strive to make AI accessible, intuitive, and helpful for everyone.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: D.t1(context).withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: D.bd(context)),
      ),
      child: Column(
        children: [
          _buildListTile(context, Icons.headset_mic_outlined, 'Contact Support',
              () => Navigator.pushNamed(context, '/help')),
          Divider(height: 1, indent: 56, color: D.bd(context)),
          _buildListTile(context, Icons.star_outline_rounded, 'Rate the App',
              () => _showRateDialog(context)),
          Divider(height: 1, indent: 56, color: D.bd(context)),
          _buildListTile(context, Icons.share_outlined, 'Share with Friends',
              () => _shareApp(context)),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: D.t1(context), size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: D.t1(context),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: D.t2(context)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _shareApp(BuildContext context) {
    final url = Uri.parse('https://smartai.app');
    showModalBottomSheet(
      context: context,
      backgroundColor: D.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Text('Share SmartAI',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600, color: D.t1(context))),
              const SizedBox(height: 20),
              _shareOption(ctx, context,
                icon: Icons.link_rounded,
                color: const Color(0xFF6366F1),
                title: 'Copy Link',
                onTap: () async {
                  Navigator.pop(ctx);
                  try { await launchUrl(url); } catch (_) {}
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link opened!')));
                  }
                },
              ),
              _shareOption(ctx, context,
                icon: Icons.email_outlined,
                color: const Color(0xFF06B6D4),
                title: 'Share via Email',
                onTap: () async {
                  Navigator.pop(ctx);
                  final emailUrl = Uri.parse(
                      'mailto:?subject=Check out SmartAI&body=Try SmartAI - your AI assistant! https://smartai.app');
                  try { await launchUrl(emailUrl); } catch (_) {}
                },
              ),
              _shareOption(ctx, context,
                icon: Icons.language_rounded,
                color: const Color(0xFF10B981),
                title: 'Open Website',
                onTap: () async {
                  Navigator.pop(ctx);
                  try { await launchUrl(url, mode: LaunchMode.externalApplication); } catch (_) {}
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shareOption(BuildContext ctx, BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, color: D.t1(context))),
      trailing: Icon(Icons.chevron_right_rounded, color: D.t2(context), size: 20),
      onTap: onTap,
    );
  }

  void _showRateDialog(BuildContext context) {
    int selectedRating = 0;
    final reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: D.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Text('Rate SmartAI',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600, color: D.t1(context))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedRating = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFFBBF24),
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              if (selectedRating > 0)
                Text(
                  ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][selectedRating],
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: const Color(0xFFFBBF24), fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 14, color: D.t1(context)),
                decoration: InputDecoration(
                  hintText: 'Write a review (optional)',
                  hintStyle: GoogleFonts.poppins(color: D.t2(context), fontSize: 14),
                  filled: true,
                  fillColor: D.bg(context),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () async {
                          final auth = context.read<AuthProvider>();
                          final user = auth.currentUser;
                          try {
                            await FirebaseFirestore.instance.collection('reviews').add({
                              'userId': user?.uid ?? '',
                              'userName': user?.displayName ?? 'Anonymous',
                              'userEmail': user?.email ?? '',
                              'rating': selectedRating,
                              'review': reviewController.text.trim(),
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Thanks for your review!'),
                                    backgroundColor: Color(0xFF10B981)),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to submit: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    disabledBackgroundColor: D.bd(context),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Submit Review',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
