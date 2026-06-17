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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const _primary = Color(0xFF5B4FE8);

  final _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'AI Chat'),
    _NavItem(icon: Icons.image_search_rounded, label: 'Image Analysis'),
    _NavItem(icon: Icons.translate_rounded, label: 'Translate'),
    _NavItem(icon: Icons.mic_outlined, label: 'Speech to Text'),
    _NavItem(icon: Icons.record_voice_over_outlined, label: 'Text to Speech'),
    _NavItem(icon: Icons.description_outlined, label: 'Documents'),
    _NavItem(icon: Icons.history_rounded, label: 'History'),
    _NavItem(icon: Icons.star_outline_rounded, label: 'Favorites'),
  ];

  final _bottomNavItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.history_rounded, label: 'History'),
    _NavItem(icon: Icons.add_circle_rounded, label: ''),
    _NavItem(icon: Icons.star_outline_rounded, label: 'Favorites'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  void _showUpgradeDialog() {
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
    final isWide = MediaQuery.of(context).size.width >= 700;

    if (isWide) {
      return _buildWideLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // ── WIDE (web/tablet) layout ─────────────────────────────────────
  Widget _buildWideLayout() {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          _Sidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onSelect: (i) => setState(() => _selectedIndex = i),
            user: user,
            onUpgrade: _showUpgradeDialog,
          ),
          Expanded(
            child: Column(
              children: [
                _WebTopBar(user: user),
                Expanded(child: _buildHomeContent(wide: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── MOBILE layout ────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(children: [
          Image.asset('assets/images/smartai.png', width: 32, height: 32),
          const SizedBox(width: 8),
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
          Stack(alignment: Alignment.topRight, children: [
            IconButton(
                icon:
                    Icon(Icons.notifications_outlined, color: Colors.grey[700]),
                onPressed: () {}),
            Positioned(
                top: 10,
                right: 10,
                child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle))),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: _Avatar(user: user, radius: 17),
            ),
          ),
        ],
      ),
      body: _buildHomeContent(wide: false),
      bottomNavigationBar: _MobileBottomNav(
        items: _bottomNavItems,
        selectedIndex: _selectedIndex,
        onSelect: (i) {
          if (i == 4)
            Navigator.pushNamed(context, '/profile');
          else if (i == 1)
            Navigator.pushNamed(context, '/history');
          else
            setState(() => _selectedIndex = i);
        },
      ),
    );
  }

  // ── Shared home content ──────────────────────────────────────────
  Widget _buildHomeContent({required bool wide}) {
    final user = context.watch<AuthProvider>().currentUser;
    final crossCount = wide ? 4 : 2;
    final aspectRatio = wide ? 1.15 : 0.95;

    return SingleChildScrollView(
      padding: EdgeInsets.all(wide ? 28 : 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Greeting
        Text('Hello, ${user?.name ?? 'User'}! 👋',
            style: GoogleFonts.poppins(
                fontSize: wide ? 26 : 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E))),
        Text('Welcome back! What would you like to do today?',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(height: 24),

        // Feature cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: aspectRatio,
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
              onTap: _showUpgradeDialog,
            ),
            FeatureCard(
              title: 'Documents',
              subtitle: 'Analyze your documents',
              icon: Icons.description_rounded,
              color: const Color(0xFF06B6D4),
              buttonLabel: 'Analyze',
              isLocked: !(user?.isPremium ?? false),
              onTap: _showUpgradeDialog,
            ),
          ],
        ),

        const SizedBox(height: 28),

        if (wide)
          // Wide: recent activity + right panel side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent activity
              Expanded(
                flex: 3,
                child: _RecentActivitySection(onUpgrade: _showUpgradeDialog),
              ),
              const SizedBox(width: 20),
              // Right panel: profile card + plan + tips
              Expanded(
                flex: 2,
                child: _RightPanel(user: user, onUpgrade: _showUpgradeDialog),
              ),
            ],
          )
        else ...[
          // Mobile: stacked
          _RecentActivitySection(onUpgrade: _showUpgradeDialog),
          const SizedBox(height: 20),
          if (!(user?.isPremium ?? false)) ...[
            UsageTracker(
              messagesUsed: user?.dailyMessagesUsed ?? 0,
              messagesLimit: user?.dailyMessagesLimit ?? 50,
              onUpgradeTap: _showUpgradeDialog,
            ),
            const SizedBox(height: 16),
            UpgradeBanner(onUpgradeTap: _showUpgradeDialog),
          ],
        ],

        const SizedBox(height: 20),
      ]),
    );
  }
}

// ── Sidebar ──────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final dynamic user;
  final VoidCallback onUpgrade;

  const _Sidebar(
      {required this.navItems,
      required this.selectedIndex,
      required this.onSelect,
      required this.user,
      required this.onUpgrade});

  static const _primary = Color(0xFF5B4FE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(children: [
              Image.asset('assets/images/smartai.png', width: 36, height: 36),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Smart',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E))),
                  TextSpan(
                      text: 'AI',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ])),
                Text('Your AI Assistant',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: Colors.grey[500])),
              ]),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: navItems.length,
              itemBuilder: (_, i) {
                final item = navItems[i];
                final selected = selectedIndex == i;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? _primary.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Icon(item.icon,
                          size: 18,
                          color: selected ? _primary : const Color(0xFF6B7280)),
                      const SizedBox(width: 10),
                      Text(item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                selected ? _primary : const Color(0xFF374151),
                          )),
                      if (selected) ...[
                        const Spacer(),
                        Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                                color: _primary, shape: BoxShape.circle)),
                      ],
                    ]),
                  ),
                );
              },
            ),
          ),

          // Divider + profile & settings
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _SidebarFooter(
              navItems: const [
                _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
                _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
                _NavItem(icon: Icons.help_outline_rounded, label: 'Support'),
                _NavItem(icon: Icons.logout_rounded, label: 'Logout'),
              ],
              onLogout: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted)
                  Navigator.pushReplacementNamed(context, '/');
              }),

          // Upgrade to Pro card
          if (!(user?.isPremium ?? false))
            _SidebarUpgradeCard(onUpgrade: onUpgrade),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final List<_NavItem> navItems;
  final VoidCallback onLogout;
  const _SidebarFooter({required this.navItems, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: navItems.map((item) {
          final isLogout = item.label == 'Logout';
          return GestureDetector(
            onTap: isLogout ? onLogout : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(children: [
                Icon(item.icon,
                    size: 18,
                    color: isLogout
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF6B7280)),
                const SizedBox(width: 10),
                Text(item.label,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isLogout
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF374151))),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SidebarUpgradeCard extends StatelessWidget {
  final VoidCallback onUpgrade;
  const _SidebarUpgradeCard({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF5B4FE8), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text('Upgrade to Pro',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          _benefit('Unlimited AI messages'),
          _benefit('Faster responses'),
          _benefit('Advanced models'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5B4FE8),
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Upgrade Now',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _benefit(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 13, color: Colors.white70),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
        ]),
      );
}

// ── Web top bar ──────────────────────────────────────────────────
class _WebTopBar extends StatelessWidget {
  final dynamic user;
  const _WebTopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(children: [
        // Search bar
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Row(children: [
              const SizedBox(width: 12),
              Icon(Icons.search_rounded, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text('Search anything...',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey[400])),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('Ctrl /',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500])),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 16),
        // Theme toggle
        IconButton(
            icon: Icon(Icons.wb_sunny_outlined, color: Colors.grey[600]),
            onPressed: () {}),
        // Notifications
        Stack(alignment: Alignment.topRight, children: [
          IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
              onPressed: () {}),
          Positioned(
              top: 8,
              right: 8,
              child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle))),
        ]),
        const SizedBox(width: 4),
        // Avatar + name
        Row(children: [
          _Avatar(user: user, radius: 18),
          const SizedBox(width: 8),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user?.name ?? 'User',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E))),
                if (user?.isPremium == true)
                  Row(children: [
                    const Icon(Icons.workspace_premium_rounded,
                        size: 11, color: Color(0xFFD97706)),
                    const SizedBox(width: 3),
                    Text('Premium',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFD97706),
                            fontWeight: FontWeight.w500)),
                  ]),
              ]),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Colors.grey[400]),
        ]),
      ]),
    );
  }
}

// ── Recent activity section ──────────────────────────────────────
class _RecentActivitySection extends StatelessWidget {
  final VoidCallback onUpgrade;
  const _RecentActivitySection({required this.onUpgrade});

  static const _primary = Color(0xFF5B4FE8);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Activity',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E))),
        Text('View all',
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
      ]),
      const SizedBox(height: 12),
      ActivityTile(
          icon: Icons.chat_bubble_rounded,
          color: _primary,
          title: 'Chat with AI',
          subtitle: 'Explain quantum computing in simple terms…',
          time: '2 minutes ago',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
      ActivityTile(
          icon: Icons.image_search_rounded,
          color: const Color(0xFF3B82F6),
          title: 'Image Analysis',
          subtitle: 'Mountains landscape.jpg',
          time: '15 minutes ago',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ImageAnalysisScreen()))),
      ActivityTile(
          icon: Icons.translate_rounded,
          color: const Color(0xFF10B981),
          title: 'Translate',
          subtitle: 'Bonjour, comment allez-vous?',
          time: '1 hour ago',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TranslateScreen()))),
      ActivityTile(
          icon: Icons.mic_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'Speech to Text',
          subtitle: 'Meeting notes voice recording',
          time: '2 hours ago',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SpeechToTextScreen()))),
    ]);
  }
}

// ── Right panel (web only) ───────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final dynamic user;
  final VoidCallback onUpgrade;
  const _RightPanel({required this.user, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Profile card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Column(children: [
          Row(children: [
            _Avatar(user: user, radius: 26),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.name ?? 'User',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF1A1A2E))),
              if (user?.isPremium == true)
                Row(children: [
                  const Icon(Icons.workspace_premium_rounded,
                      size: 13, color: Color(0xFFD97706)),
                  const SizedBox(width: 4),
                  Text('Premium User',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.w600)),
                ]),
            ]),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _statCol('125', 'AI Chats'),
            _divider(),
            _statCol('48', 'Images Analyzed'),
            _divider(),
            _statCol('32', 'Translations'),
            _divider(),
            _statCol('18', 'Hours Saved'),
          ]),
        ]),
      ),
      const SizedBox(height: 14),

      // Plan + usage
      UsageTracker(
        messagesUsed: user?.dailyMessagesUsed ?? 0,
        messagesLimit: user?.dailyMessagesLimit ?? 50,
        onUpgradeTap: onUpgrade,
      ),
      const SizedBox(height: 14),

      // Tips
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tips for you',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          _tip(
              Icons.mic_rounded,
              const Color(0xFF8B5CF6),
              'Try voice commands for faster input',
              'Use speech to text feature'),
          const SizedBox(height: 10),
          _tip(
              Icons.image_rounded,
              const Color(0xFF3B82F6),
              'Upload clear images for better analysis',
              'High quality images give better results'),
          const SizedBox(height: 10),
          _tip(Icons.bookmark_rounded, const Color(0xFF5B4FE8),
              'Save your favorite conversations', 'Bookmark important chats'),
        ]),
      ),

      // Upgrade banner (free users only)
      if (!(user?.isPremium ?? false)) ...[
        const SizedBox(height: 14),
        UpgradeBanner(onUpgradeTap: onUpgrade),
      ],
    ]);
  }

  Widget _statCol(String val, String label) => Column(children: [
        Text(val,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E))),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
            textAlign: TextAlign.center),
      ]);

  Widget _divider() =>
      Container(height: 32, width: 1, color: const Color(0xFFE5E7EB));

  Widget _tip(IconData icon, Color color, String title, String subtitle) =>
      Row(children: [
        Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 17)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A2E))),
          Text(subtitle,
              style:
                  GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
        ])),
      ]);
}

// ── Mobile bottom nav ────────────────────────────────────────────
class _MobileBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _MobileBottomNav(
      {required this.items,
      required this.selectedIndex,
      required this.onSelect});

  static const _primary = Color(0xFF5B4FE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final selected = selectedIndex == i;
          if (i == 2) {
            // Center FAB
            return GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x335B4FE8),
                          blurRadius: 12,
                          offset: Offset(0, 4))
                    ]),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 26),
              ),
            );
          }
          return GestureDetector(
            onTap: () => onSelect(i),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(item.icon,
                  size: 22, color: selected ? _primary : Colors.grey[400]),
              const SizedBox(height: 3),
              Text(item.label,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: selected ? _primary : Colors.grey[400],
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final dynamic user;
  final double radius;
  const _Avatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF5B4FE8).withOpacity(0.1),
      backgroundImage:
          user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
      child: user?.avatarUrl == null
          ? Text(
              user?.name?.isNotEmpty == true
                  ? user!.name[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                  color: const Color(0xFF5B4FE8),
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.8))
          : null,
    );
  }
}

// ── Data class ───────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
