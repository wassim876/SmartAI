import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'chat_screen.dart';
import 'translate_screen.dart';
import 'speech_to_text_screen.dart';
import 'image_analysis_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _primary = Color(0xFF5B4FE8);
  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final used = user?.dailyMessagesUsed ?? 0;
    final limit = user?.dailyMessagesLimit ?? 50;
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: _primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SmartAI',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primary)),
            Text('Your AI Assistant',
                style:
                    GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
          ]),
        ]),
        actions: [
          IconButton(
            icon: Navigator.canPop(context)
                ? const Icon(Icons.history_rounded, color: Color(0xFF374151))
                : Stack(children: [
                    const Icon(Icons.notifications_outlined,
                        color: Color(0xFF374151)),
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle))),
                  ]),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _primary.withOpacity(0.1),
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15))
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Greeting
          Text('Hello, ${user?.name ?? 'User'}! 👋',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E))),
          Text('What would you like to do today?',
              style:
                  GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 22),

          // Feature cards 2x2
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: [
              _FeatureCard(
                title: 'Chat with AI',
                subtitle: 'Ask anything and get intelligent answers',
                icon: Icons.chat_bubble_rounded,
                color: _primary,
                buttonLabel: 'Start Chat',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChatScreen())),
              ),
              _FeatureCard(
                title: 'Translate',
                subtitle: 'Translate text between 100+ languages',
                icon: Icons.translate_rounded,
                color: const Color(0xFF10B981),
                buttonLabel: 'Translate Now',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TranslateScreen())),
              ),
              _FeatureCard(
                title: 'Image Analysis',
                subtitle: 'Upload an image and get AI insights',
                icon: Icons.image_search_rounded,
                color: const Color(0xFF3B82F6),
                buttonLabel: 'Analyze Image',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ImageAnalysisScreen())),
              ),
              _FeatureCard(
                title: 'Speech to Text',
                subtitle: 'Convert speech to text instantly',
                icon: Icons.mic_rounded,
                color: const Color(0xFF8B5CF6),
                buttonLabel: 'Start Recording',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SpeechToTextScreen())),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Recent Activity',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E))),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/history'),
              child: Text('View all',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary)),
            ),
          ]),
          const SizedBox(height: 12),

          ...[
            _ActivityRow(
                icon: Icons.chat_bubble_rounded,
                color: _primary,
                title: 'Chat with AI',
                subtitle: 'Explain quantum computing in simple terms…',
                time: '2 minutes ago'),
            _ActivityRow(
                icon: Icons.image_search_rounded,
                color: const Color(0xFF3B82F6),
                title: 'Image Analysis',
                subtitle: 'Mountains landscape.jpg',
                time: '15 minutes ago'),
            _ActivityRow(
                icon: Icons.translate_rounded,
                color: const Color(0xFF10B981),
                title: 'Translate',
                subtitle: 'Bonjour, comment allez-vous?',
                time: '1 hour ago'),
            _ActivityRow(
                icon: Icons.mic_rounded,
                color: const Color(0xFF8B5CF6),
                title: 'Speech to Text',
                subtitle: 'Meeting notes voice recording',
                time: '2 hours ago'),
          ],

          const SizedBox(height: 24),

          // Plan / usage card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Your Plan',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF1A1A2E))),
                const SizedBox(width: 8),
                if (user?.isPremium == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('⭐ Premium',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD97706))),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEECFD),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Free',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _primary)),
                  ),
              ]),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Requests Used',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[500])),
                Text('$used / $limit',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E))),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEECFD),
                    valueColor: const AlwaysStoppedAnimation(_primary),
                  )),
              const SizedBox(height: 8),
              Text('Renews on July 15, 2024',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey[400])),
            ]),
          ),

          const SizedBox(height: 20),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tips for you',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF1A1A2E))),
              const SizedBox(height: 12),
              _Tip(
                  icon: Icons.mic_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: 'Try voice commands for faster input',
                  subtitle: 'Use speech to text feature'),
              const SizedBox(height: 10),
              _Tip(
                  icon: Icons.image_rounded,
                  color: const Color(0xFF3B82F6),
                  title: 'Upload clear images for better analysis',
                  subtitle: 'High quality images give better results'),
              const SizedBox(height: 10),
              _Tip(
                  icon: Icons.bookmark_rounded,
                  color: _primary,
                  title: 'Save your favorite conversations',
                  subtitle: 'Bookmark important chats'),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title, subtitle, buttonLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FeatureCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.buttonLabel,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 8),
        Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF1A1A2E))),
        const SizedBox(height: 2),
        Text(subtitle,
            style: GoogleFonts.poppins(
                fontSize: 10, color: Colors.grey[500], height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(buttonLabel,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle, time;
  const _ActivityRow(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF1A1A2E))),
          Text(subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(time,
              style:
                  GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400])),
          const SizedBox(height: 4),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: Color(0xFFD1D5DB)),
        ]),
      ]),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _Tip(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E))),
        Text(subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
      ])),
    ]);
  }
}
