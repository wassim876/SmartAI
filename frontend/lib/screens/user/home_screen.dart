import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/usage_tracker.dart';
import '../../widgets/upgrade_banner.dart';
import '../../widgets/activity_tile.dart';
import 'chat_screen.dart';
import 'translate_screen.dart';
import 'speech_to_text_screen.dart';
import 'image_analysis_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _primary = Color(0xFF5B4FE8);
  static const _bg = Color(0xFFF5F6FA);

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: UpgradeBanner(onUpgradeTap: () => Navigator.pop(context)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
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
            icon: Stack(children: [
              Icon(Icons.notifications_outlined, color: Colors.grey[700]),
              Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle))),
            ]),
            onPressed: () {},
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
                            fontSize: 15),
                      )
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
          Text(
            'Hello, ${user?.name ?? 'User'}! 👋',
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E)),
          ),
          Text(
            'What would you like to do today?',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 22),

          // Feature cards grid — uses FeatureCard widget
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.88,
            children: [
              FeatureCard(
                title: 'Chat with AI',
                subtitle: 'Ask anything and get intelligent answers',
                icon: Icons.chat_bubble_rounded,
                color: _primary,
                buttonLabel: 'Start Chat',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChatScreen())),
              ),
              FeatureCard(
                title: 'Translate',
                subtitle: 'Translate text between 100+ languages',
                icon: Icons.translate_rounded,
                color: const Color(0xFF10B981),
                buttonLabel: 'Translate Now',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TranslateScreen())),
              ),
              FeatureCard(
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
              FeatureCard(
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
              FeatureCard(
                title: 'Text to Speech',
                subtitle: 'Convert text to voice',
                icon: Icons.record_voice_over_rounded,
                color: const Color(0xFFF59E0B),
                buttonLabel: 'Convert',
                isLocked: !(user?.isPremium ?? false),
                onTap: () => _showUpgradeDialog(context),
              ),
              FeatureCard(
                title: 'Documents',
                subtitle: 'Analyze your documents with AI',
                icon: Icons.description_rounded,
                color: const Color(0xFF06B6D4),
                buttonLabel: 'Analyze',
                isLocked: !(user?.isPremium ?? false),
                onTap: () => _showUpgradeDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity — uses ActivityTile widget
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

          ActivityTile(
            icon: Icons.chat_bubble_rounded,
            color: _primary,
            title: 'Chat with AI',
            subtitle: 'Explain quantum computing in simple terms…',
            time: '2 minutes ago',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ChatScreen())),
          ),
          ActivityTile(
            icon: Icons.image_search_rounded,
            color: const Color(0xFF3B82F6),
            title: 'Image Analysis',
            subtitle: 'Mountains landscape.jpg',
            time: '15 minutes ago',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ImageAnalysisScreen())),
          ),
          ActivityTile(
            icon: Icons.translate_rounded,
            color: const Color(0xFF10B981),
            title: 'Translate',
            subtitle: 'Bonjour, comment allez-vous?',
            time: '1 hour ago',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TranslateScreen())),
          ),
          ActivityTile(
            icon: Icons.mic_rounded,
            color: const Color(0xFF8B5CF6),
            title: 'Speech to Text',
            subtitle: 'Meeting notes voice recording',
            time: '2 hours ago',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SpeechToTextScreen())),
          ),

          const SizedBox(height: 24),

          // Usage tracker — uses UsageTracker widget (only for free users)
          if (!(user?.isPremium ?? false)) ...[
            UsageTracker(
              messagesUsed: user?.dailyMessagesUsed ?? 0,
              messagesLimit: user?.dailyMessagesLimit ?? 50,
              onUpgradeTap: () => _showUpgradeDialog(context),
            ),
            const SizedBox(height: 20),
          ],

          // Upgrade banner — uses UpgradeBanner widget (only for free users)
          if (!(user?.isPremium ?? false))
            UpgradeBanner(onUpgradeTap: () => _showUpgradeDialog(context)),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
