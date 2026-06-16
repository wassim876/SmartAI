import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/usage_tracker.dart';
import '../../widgets/upgrade_banner.dart';
import 'chat_screen.dart';
import 'translate_screen.dart';
import 'speech_to_text_screen.dart';
import 'image_analysis_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  static const _primary = Color(0xFF5B4FE8);
  static const _bg = Color(0xFFF5F6FA);

  final _pages = const [_HomeTab(), HistoryScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SmartAI', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _primary)),
            Text('Your AI Assistant', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
          ]),
        ]),
        actions: [
          IconButton(
            icon: Stack(children: [
              Icon(Icons.notifications_outlined, color: Colors.grey[700]),
              Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ]),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 2),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _primary.withOpacity(0.1),
                backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                child: user?.avatarUrl == null
                    ? Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 16))
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: _primary,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  static const _primary = Color(0xFF5B4FE8);

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.workspace_premium_rounded, color: Colors.amber[700]),
          const SizedBox(width: 8),
          Text('Upgrade to Premium', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Unlock all features:', style: GoogleFonts.poppins(color: Colors.grey[600])),
          const SizedBox(height: 12),
          _dialogItem('Unlimited AI messages'),
          _dialogItem('Image & document analysis'),
          _dialogItem('Text to speech conversion'),
          _dialogItem('Priority support'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Maybe Later', style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Upgrade Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _dialogItem(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF22C55E)),
      const SizedBox(width: 8),
      Text(text, style: GoogleFonts.poppins(fontSize: 13)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        // Greeting
        Text('Hello, ${user?.name ?? 'User'}! 👋',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
        Text('What would you like to do today?',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(height: 20),

        // Feature cards grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05,
          children: [
            _FeatureTile(title: 'AI Chat', subtitle: 'Talk with AI assistant', icon: Icons.chat_bubble_rounded, color: _primary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
            _FeatureTile(title: 'Translate', subtitle: 'Translate text instantly', icon: Icons.translate_rounded, color: const Color(0xFF10B981),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslateScreen()))),
            _FeatureTile(title: 'Image Analysis', subtitle: 'Analyze images with AI', icon: Icons.image_search_rounded, color: const Color(0xFF3B82F6),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageAnalysisScreen()))),
            _FeatureTile(title: 'Speech to Text', subtitle: 'Convert speech to text', icon: Icons.mic_rounded, color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeechToTextScreen()))),
            _FeatureTile(title: 'Text to Speech', subtitle: 'Convert text to voice', icon: Icons.record_voice_over_rounded, color: const Color(0xFFF59E0B),
                isLocked: !(user?.isPremium ?? false), onTap: () => _showUpgradeDialog(context)),
            _FeatureTile(title: 'Documents', subtitle: 'Analyze your documents', icon: Icons.description_rounded, color: const Color(0xFF06B6D4),
                isLocked: !(user?.isPremium ?? false), onTap: () => _showUpgradeDialog(context)),
          ],
        ),

        const SizedBox(height: 24),

        // Usage tracker
        if (!(user?.isPremium ?? false)) ...[
          _UsageCard(user: user, onUpgrade: () => _showUpgradeDialog(context)),
          const SizedBox(height: 20),
        ],

        // Upgrade banner
        if (!(user?.isPremium ?? false))
          _UpgradeBannerCard(onTap: () => _showUpgradeDialog(context)),
      ]),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final VoidCallback onTap;
  const _FeatureTile({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            if (isLocked) Icon(Icons.lock_rounded, size: 16, color: Colors.grey[400]),
          ]),
          const Spacer(),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback onUpgrade;
  const _UsageCard({this.user, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final used = user?.dailyMessagesUsed ?? 0;
    final limit = user?.dailyMessagesLimit ?? 50;
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Daily Usage', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF1A1A2E))),
          GestureDetector(
            onTap: onUpgrade,
            child: Text('Upgrade ↗', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5B4FE8))),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
          value: progress, minHeight: 8,
          backgroundColor: const Color(0xFFEEECFD),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF5B4FE8)),
        )),
        const SizedBox(height: 8),
        Text('$used of $limit messages used today', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
      ]),
    );
  }
}

class _UpgradeBannerCard extends StatelessWidget {
  final VoidCallback onTap;
  const _UpgradeBannerCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF5B4FE8), Color(0xFF8B5CF6)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Unlock More with Premium', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Get unlimited access to all AI features and priority support.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text('Upgrade Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF5B4FE8))),
            ),
          ),
        ])),
        const SizedBox(width: 12),
        const Icon(Icons.smart_toy_rounded, size: 64, color: Colors.white24),
      ]),
    );
  }
}