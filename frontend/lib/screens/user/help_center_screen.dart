import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});
  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const _primary = AppColors.primary;
  static const _bg = Color(0xFFF4F6FB);
  static const _text1 = AppColors.textDark;
  static const _text2 = AppColors.textGrey;
  static const _border = Color(0xFFEAEAF4);
  static const _email = 'smartai_support@openai.com';

  int? _openFaq;

  final _faqs = const [
    _Faq('How do I start a chat with AI?',
        'Tap "AI Chat" from the home screen or sidebar. Type your message and press send. The AI will respond instantly.'),
    _Faq('How does Image Analysis work?',
        'Go to Image Analysis, tap the upload area to pick a photo from your gallery or camera, then tap "Analyze Image". The AI will describe and analyze the content.'),
    _Faq('How many messages can I send per day?',
        'Free users get 50 messages per day. Premium users get unlimited messages. Your usage resets every 24 hours.'),
    _Faq('How does Speech to Text work?',
        'Open Speech to Text, tap the microphone button and speak clearly. The app will transcribe your voice in real time.'),
    _Faq('How do I upgrade to Premium?',
        'Tap "Upgrade" on any locked feature or check your Settings to see subscription options. Premium gives you unlimited access to all features.'),
    _Faq('Can I use SmartAI offline?',
        'No, SmartAI requires an internet connection to process AI requests. Make sure you have a stable connection.'),
    _Faq('How do I reset my password?',
        'On the login screen, tap "Forgot password?" and enter your email. You will receive a reset link shortly.'),
    _Faq('Is my data secure?',
        'Yes. All data is encrypted in transit using HTTPS. We never sell your personal data to third parties.'),
    _Faq('How do I delete my account?',
        'Contact our support team at $_email and we will process your account deletion within 48 hours.'),
  ];

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {
        'subject': 'SmartAI Support Request',
        'body': 'Hello SmartAI Support,\n\nI need help with:\n\n',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(const ClipboardData(text: _email));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email copied: $_email'),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _text1),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Help Center',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w600, color: _text1)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Hero ──────────────────────────────────────────────────
          Container(
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
                    color: _primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 14),
              Text('How can we help you?',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 6),
              Text('Find answers or contact our support team',
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                  textAlign: TextAlign.center),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Quick links ───────────────────────────────────────────
          Text('Quick Help',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _text1)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _QuickCard(
                    icon: Icons.chat_bubble_rounded,
                    color: _primary,
                    label: 'AI Chat Help',
                    onTap: () => setState(() => _openFaq = 0))),
            const SizedBox(width: 12),
            Expanded(
                child: _QuickCard(
                    icon: Icons.mic_rounded,
                    color: const Color(0xFF8B5CF6),
                    label: 'Speech to Text',
                    onTap: () => setState(() => _openFaq = 3))),
            const SizedBox(width: 12),
            Expanded(
                child: _QuickCard(
                    icon: Icons.workspace_premium_rounded,
                    color: const Color(0xFFF59E0B),
                    label: 'Premium',
                    onTap: () => setState(() => _openFaq = 5))),
          ]),

          const SizedBox(height: 28),

          // ── FAQ ───────────────────────────────────────────────────
          Text('Frequently Asked Questions',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _text1)),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: _faqs.asMap().entries.map((e) {
                final i = e.key;
                final faq = e.value;
                final isOpen = _openFaq == i;
                final isLast = i == _faqs.length - 1;
                return Column(children: [
                  InkWell(
                    onTap: () => setState(() => _openFaq = isOpen ? null : i),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      child: Row(children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isOpen ? _primary : _bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isOpen ? Icons.remove_rounded : Icons.add_rounded,
                            size: 16,
                            color: isOpen ? Colors.white : _text2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(faq.q,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: isOpen
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isOpen ? _primary : _text1,
                                ))),
                      ]),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                          left: 58, right: 18, bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: _primary.withValues(alpha: 0.1)),
                      ),
                      child: Text(faq.a,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: _text2, height: 1.6)),
                    ),
                    crossFadeState: isOpen
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  if (!isLast) const Divider(height: 1, color: _border),
                ]);
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          // ── Contact support ───────────────────────────────────────
          Text('Still need help?',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _text1)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(children: [
              // Email card
              InkWell(
                onTap: _launchEmail,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(13)),
                      child: const Icon(Icons.email_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Email Support',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: _text1)),
                          const SizedBox(height: 3),
                          Text(_email,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _primary,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text('We reply within 24 hours',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: _text2)),
                        ])),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: _text2),
                  ]),
                ),
              ),

              const SizedBox(height: 14),

              // Copy email button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(const ClipboardData(text: _email));
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Email address copied!'),
                          backgroundColor: _primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text('Copy Email Address',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem('Response', '< 24h'),
                  _infoItem('Support', '24/7'),
                  _infoItem('Reliability', '100%'),
                ],
              ),
            ]),
          ),

          const SizedBox(height: 28),
        ]),
      ),
    );
  }

  Widget _infoItem(String label, String value) => Column(children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w700, color: _text1)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: _text2)),
      ]);
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _QuickCard(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAF4)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF12112A)),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

class _Faq {
  final String q, a;
  const _Faq(this.q, this.a);
}
