import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/dark_mode_helpers.dart';
import '../../l10n/app_localizations.dart'; // ✅ Add this import

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});
  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const _primary = Color(0xFF5B4FE8);
  static const _email = 'smartai_support@openai.com';

  int? _openFaq;

  // ✅ Remove hardcoded FAQ - we'll use translations
  // _faqs will be built dynamically in build method

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
            content: Text('${AppLocalizations.of(context).translate('emailCopied')}: $_email'),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    // ✅ Build FAQ list with translations
    final faqs = [
      _Faq(
        loc.translate('howToStartChat'),
        loc.translate('howToStartChatAnswer'),
      ),
      _Faq(
        loc.translate('howImageAnalysisWorks'),
        loc.translate('howImageAnalysisWorksAnswer'),
      ),
      _Faq(
        loc.translate('howManyMessages'),
        loc.translate('howManyMessagesAnswer'),
      ),
      _Faq(
        loc.translate('howSpeechToTextWorks'),
        loc.translate('howSpeechToTextWorksAnswer'),
      ),
      _Faq(
        loc.translate('howToUpgrade'),
        loc.translate('howToUpgradeAnswer'),
      ),
      _Faq(
        loc.translate('canUseOffline'),
        loc.translate('canUseOfflineAnswer'),
      ),
      _Faq(
        loc.translate('howToResetPassword'),
        loc.translate('howToResetPasswordAnswer'),
      ),
      _Faq(
        loc.translate('isDataSecure'),
        loc.translate('isDataSecureAnswer'),
      ),
      _Faq(
        loc.translate('howToDeleteAccount'),
        loc.translate('howToDeleteAccountAnswer'),
      ),
    ];

    return Scaffold(
      backgroundColor: D.bg(context),
      appBar: AppBar(
        backgroundColor: D.appBar(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: D.t1(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate('helpCenter'), // ✅
          style: GoogleFonts.poppins(
              fontSize: 17, fontWeight: FontWeight.w600, color: D.t1(context)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              Text(
                loc.translate('howCanWeHelp'), // ✅
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                loc.translate('findAnswers'), // ✅
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ]),
          ),

          const SizedBox(height: 24),

          Text(
            loc.translate('quickHelp'), // ✅
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700, color: D.t1(context)),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _QuickCard(
                    icon: Icons.chat_bubble_rounded,
                    color: _primary,
                    label: loc.translate('aiChatHelp'), // ✅
                    onTap: () => setState(() => _openFaq = 0))),
            const SizedBox(width: 12),
            Expanded(
                child: _QuickCard(
                    icon: Icons.mic_rounded,
                    color: const Color(0xFF8B5CF6),
                    label: loc.translate('speechToText'), // ✅
                    onTap: () => setState(() => _openFaq = 3))),
            const SizedBox(width: 12),
            Expanded(
                child: _QuickCard(
                    icon: Icons.workspace_premium_rounded,
                    color: const Color(0xFFF59E0B),
                    label: loc.translate('upgradeToPremium'),
                    onTap: () => setState(() => _openFaq = 4))),
          ]),

          const SizedBox(height: 28),

          Text(
            loc.translate('frequentlyAsked'), // ✅
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700, color: D.t1(context)),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: D.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: D.bd(context)),
            ),
            child: Column(
              children: faqs.asMap().entries.map((e) {
                final i = e.key;
                final faq = e.value;
                final isOpen = _openFaq == i;
                final isLast = i == faqs.length - 1;
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
                            color: isOpen ? _primary : D.bg(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isOpen ? Icons.remove_rounded : Icons.add_rounded,
                            size: 16,
                            color: isOpen ? Colors.white : D.t2(context),
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
                                  color: isOpen ? _primary : D.t1(context),
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
                              fontSize: 12, color: D.t2(context), height: 1.6)),
                    ),
                    crossFadeState: isOpen
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  if (!isLast) Divider(height: 1, color: D.bd(context)),
                ]);
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            loc.translate('stillNeedHelp'), // ✅
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700, color: D.t1(context)),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: D.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: D.bd(context)),
            ),
            child: Column(children: [
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
                          Text(
                            loc.translate('emailSupport'), // ✅
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: D.t1(context)),
                          ),
                          const SizedBox(height: 3),
                          Text(_email,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _primary,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            loc.translate('weReply'), // ✅
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: D.t2(context)),
                          ),
                        ])),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: D.t2(context)),
                  ]),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(const ClipboardData(text: _email));
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(loc.translate('emailCopied')), // ✅
                          backgroundColor: _primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(
                    loc.translate('copyEmailAddress'), // ✅
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: D.bd(context)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: D.bd(context)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(
                    loc.translate('response'), // ✅
                    '< 24h',
                    context,
                  ),
                  _infoItem(
                    loc.translate('support'), // ✅
                    '24/7',
                    context,
                  ),
                  _infoItem(
                    loc.translate('reliability'), // ✅
                    '100%',
                    context,
                  ),
                ],
              ),
            ]),
          ),

          const SizedBox(height: 28),
        ]),
      ),
    );
  }

  Widget _infoItem(String label, String value, BuildContext context) => Column(children: [
    Text(value,
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w700, color: D.t1(context))),
    Text(label, style: GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
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
            color: D.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: D.bd(context)),
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
                    color: D.t1(context)),
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