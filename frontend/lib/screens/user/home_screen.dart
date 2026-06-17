import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/activity_tile.dart';
import 'chat_screen.dart';
import 'user_settings_screen.dart';
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

  static const _primary = Color(0xFF6C63FF);
  static const _surface = Colors.white;
  static const _bg = Color(0xFFF4F6FB);
  static const _text1 = Color(0xFF12112A);
  static const _text2 = Color(0xFF7B7A8E);
  static const _border = Color(0xFFEAEAF4);

  final _features = const [
    _Feature('AI Chat', 'Ask anything, get intelligent answers',
        Icons.auto_awesome_rounded, Color(0xFF6C63FF), Color(0xFFEEEDFF)),
    _Feature('Translate', 'Translate across 100+ languages',
        Icons.translate_rounded, Color(0xFF10B981), Color(0xFFD1FAE5)),
    _Feature('Image Analysis', 'Upload an image, get AI insights',
        Icons.image_search_rounded, Color(0xFF3B82F6), Color(0xFFDBEAFE)),
    _Feature('Speech to Text', 'Turn your voice into text instantly',
        Icons.mic_rounded, Color(0xFF8B5CF6), Color(0xFFEDE9FE)),
    _Feature('Text to Speech', 'Convert any text to natural voice',
        Icons.record_voice_over_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _Feature('Documents', 'Analyze & summarize your documents',
        Icons.description_rounded, Color(0xFF06B6D4), Color(0xFFCFFAFE)),
  ];

  final _navItems = const [
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.auto_awesome_rounded, 'AI Chat'),
    _NavItem(Icons.image_search_rounded, 'Image Analysis'),
    _NavItem(Icons.translate_rounded, 'Translate'),
    _NavItem(Icons.mic_outlined, 'Speech to Text'),
    _NavItem(Icons.record_voice_over_outlined, 'Text to Speech'),
    _NavItem(Icons.description_outlined, 'Documents'),
    _NavItem(Icons.history_rounded, 'History'),
    _NavItem(Icons.star_outline_rounded, 'Favorites'),
  ];

  void _navigate(int i) {
    final user = context.read<AuthProvider>().currentUser;
    setState(() => _selectedIndex = i);
    switch (i) {
      case 1:
        Navigator.push(context, _route(const ChatScreen()));
        break;
      case 2:
        Navigator.push(context, _route(const ImageAnalysisScreen()));
        break;
      case 3:
        Navigator.push(context, _route(const TranslateScreen()));
        break;
      case 4:
        Navigator.push(context, _route(const SpeechToTextScreen()));
        break;
      case 5:
      case 6:
        if (user?.isPremium ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feature coming soon!')));
        } else {
          _showUpgrade();
        }
        break;
      case 7:
        Navigator.pushNamed(context, '/history');
        break;
      case 8:
        Navigator.pushNamed(context, '/history');
        break;
    }
  }

  PageRoute _route(Widget page) => MaterialPageRoute(builder: (_) => page);

  void _showUpgrade() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9F7AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(height: 14),
                Text('Upgrade to Premium',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Unlock unlimited AI power and priority access.',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 20),
                ...[
                  'Unlimited AI messages',
                  'Image & document analysis',
                  'Faster response time',
                  'Priority support',
                ].map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 10),
                        Text(t,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 13)),
                      ]),
                    )),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Upgrade Now',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  )),
                  const SizedBox(width: 12),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Later',
                          style: GoogleFonts.poppins(color: Colors.white70))),
                ]),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;
    return wide ? _wide() : _mobile();
  }

  // ── WIDE layout ─────────────────────────────────────────────────
  Widget _wide() {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: _bg,
      body: Row(children: [
        _Sidebar(
            items: _navItems,
            selected: _selectedIndex,
            onTap: _navigate,
            user: user,
            onUpgrade: _showUpgrade),
        Expanded(
            child: Column(children: [
          _TopBar(user: user),
          Expanded(child: _content(wide: true)),
        ])),
      ]),
    );
  }

  // ── MOBILE layout ───────────────────────────────────────────────
  Widget _mobile() {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildMobileAppBar(user),
      body: _content(wide: false),
      bottomNavigationBar: _BottomNav(
        selected: _selectedIndex,
        onTap: (i) {
          if (i == 4) {
            Navigator.push(context, _route(const UserSettingsScreen()));
          } else if (i == 1)
            Navigator.pushNamed(context, '/history');
          else if (i == 2)
            Navigator.push(context, _route(const ChatScreen()));
          else
            setState(() => _selectedIndex = i);
        },
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(dynamic user) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 18,
      title: Row(children: [
        // Bigger logo
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/images/smartai.png',
              width: 44, height: 44, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Smart',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _text1)),
            TextSpan(
                text: 'AI',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _primary)),
          ])),
          Text('Your AI Assistant',
              style: GoogleFonts.poppins(fontSize: 10, color: _text2)),
        ]),
      ]),
      actions: [
        _NotifBell(),
        const SizedBox(width: 4),
        GestureDetector(
          // Avatar tap for mobile
          onTap: () =>
              Navigator.push(context, _route(const UserSettingsScreen())),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Avatar(user: user, radius: 19),
          ),
        ),
      ],
    );
  }

  // ── Main content ─────────────────────────────────────────────────
  Widget _content({required bool wide}) {
    final user = context.watch<AuthProvider>().currentUser;
    final cols = wide ? 3 : 2;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          wide ? 32 : 18, wide ? 28 : 20, wide ? 32 : 18, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Hero greeting ──────────────────────────────────────────
        _HeroGreeting(user: user, wide: wide),
        SizedBox(height: wide ? 32 : 22),

        // ── Quick stats row (web only) ─────────────────────────────
        if (wide) ...[
          _QuickStats(user: user),
          const SizedBox(height: 28),
        ],

        // ── Section label ──────────────────────────────────────────
        _SectionLabel(
            title: 'AI Features', subtitle: 'Choose a tool to get started'),
        const SizedBox(height: 14),

        // ── Feature grid ──────────────────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: wide ? 1.6 : 0.85,
          ),
          itemCount: _features.length,
          itemBuilder: (_, i) {
            final f = _features[i];
            final locked = i >= 4 && !(user?.isPremium ?? false);
            return _FeatureCard(
              feature: f,
              locked: locked,
              wide: wide,
              onTap: locked
                  ? _showUpgrade
                  : () {
                      switch (i) {
                        case 0:
                          Navigator.push(context, _route(const ChatScreen()));
                          break;
                        case 1:
                          Navigator.push(
                              context, _route(const TranslateScreen()));
                          break;
                        case 2:
                          Navigator.push(
                              context, _route(const ImageAnalysisScreen()));
                          break;
                        case 3:
                          Navigator.push(
                              context, _route(const SpeechToTextScreen()));
                          break;
                        default:
                          // Handle other features or show placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Feature coming soon!')));
                          break;
                      }
                    },
            );
          },
        ),

        SizedBox(height: wide ? 32 : 24),

        if (wide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: _ActivitySection()),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: _RightPanel(user: user)),
          ])
        else ...[
          _ActivitySection(),
          const SizedBox(height: 20),
          if (!(user?.isPremium ?? false))
            _UsageMini(user: user, onUpgrade: _showUpgrade),
        ],

        const SizedBox(height: 20),
      ]),
    );
  }
}

// ── Hero greeting ─────────────────────────────────────────────────
class _HeroGreeting extends StatelessWidget {
  final dynamic user;
  final bool wide;
  const _HeroGreeting({required this.user, required this.wide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 28 : 20),
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
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, ${user?.username ?? 'User'}! 👋',
              style: GoogleFonts.poppins(
                  fontSize: wide ? 26 : 21,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text('Welcome back! What would you like to do today?',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white70, height: 1.5)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _HeroPill(icon: Icons.auto_awesome_rounded, label: 'AI Powered'),
            _HeroPill(icon: Icons.bolt_rounded, label: 'Instant Results'),
          ]),
        ])),
        if (wide) ...[
          const SizedBox(width: 20),
          Image.asset('assets/images/home_ai.png', width: 90, height: 90),
        ],
      ]),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── Quick stats (web) ─────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  final dynamic user;
  const _QuickStats({required this.user});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('125', 'AI Chats', Icons.chat_bubble_rounded, const Color(0xFF6C63FF)),
      ('48', 'Images', Icons.image_rounded, const Color(0xFF3B82F6)),
      ('32', 'Translations', Icons.translate_rounded, const Color(0xFF10B981)),
      (
        '18h',
        'Hours Saved',
        Icons.access_time_rounded,
        const Color(0xFFF59E0B)
      ),
    ];
    return Row(
      children: stats
          .map((s) => Expanded(
                  child: Padding(
                padding: EdgeInsets.only(right: s == stats.last ? 0 : 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAEAF4)),
                  ),
                  child: Row(children: [
                    Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: s.$4.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(s.$3, color: s.$4, size: 19)),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.$1,
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF12112A))),
                          Text(s.$2,
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF7B7A8E))),
                        ]),
                  ]),
                ),
              )))
          .toList(),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title, subtitle;
  const _SectionLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF12112A))),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF7B7A8E))),
          ]),
        ]);
  }
}

// ── Feature card ──────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final bool locked, wide;
  final VoidCallback onTap;
  const _FeatureCard(
      {required this.feature,
      required this.locked,
      required this.wide,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF4)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4))
            ],
          ),
          child: wide ? _wideContent() : _mobileContent(),
        ),
      ),
    );
  }

  Widget _wideContent() => Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: feature.bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(feature.icon, color: feature.color, size: 24)),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Row(children: [
                Expanded(
                    child: Text(feature.title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: const Color(0xFF12112A)))),
                if (locked)
                  const Icon(Icons.lock_rounded,
                      size: 14, color: Color(0xFFB0B0C8)),
              ]),
              const SizedBox(height: 3),
              Text(feature.subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF7B7A8E),
                      height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ])),
      ]);

  Widget _mobileContent() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: feature.bg, borderRadius: BorderRadius.circular(13)),
              child: Icon(feature.icon, color: feature.color, size: 22)),
          if (locked)
            const Icon(Icons.lock_rounded, size: 14, color: Color(0xFFB0B0C8)),
        ]),
        const Spacer(),
        Text(feature.title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: const Color(0xFF12112A))),
        const SizedBox(height: 3),
        Text(feature.subtitle,
            style: GoogleFonts.poppins(
                fontSize: 10, color: const Color(0xFF7B7A8E), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: locked ? const Color(0xFFF0F0F8) : feature.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Text(
            locked ? '🔒 Upgrade' : 'Open',
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: locked ? const Color(0xFFB0B0C8) : Colors.white),
          )),
        ),
      ]);
}

// ── Activity section ──────────────────────────────────────────────
class _ActivitySection extends StatelessWidget {
  static const _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Activity',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF12112A))),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/history'),
          child: Text('View all →',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
        ),
      ]),
      const SizedBox(height: 12),
      ActivityTile(
          icon: Icons.auto_awesome_rounded,
          color: _primary,
          title: 'Chat with AI',
          subtitle: 'Explain quantum computing in simple terms…',
          time: '2 min ago',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
      ActivityTile(
          icon: Icons.image_search_rounded,
          color: const Color(0xFF3B82F6),
          title: 'Image Analysis',
          subtitle: 'Mountains landscape.jpg',
          time: '15 min ago',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ImageAnalysisScreen()))),
      ActivityTile(
          icon: Icons.translate_rounded,
          color: const Color(0xFF10B981),
          title: 'Translate',
          subtitle: 'Bonjour, comment allez-vous?',
          time: '1 hr ago',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TranslateScreen()))),
      ActivityTile(
          icon: Icons.mic_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'Speech to Text',
          subtitle: 'Meeting notes voice recording',
          time: '2 hr ago',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SpeechToTextScreen()))),
    ]);
  }
}

// ── Right panel (web) ─────────────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final dynamic user;
  const _RightPanel({required this.user});

  @override
  Widget build(BuildContext context) {
    final used = user?.dailyMessagesUsed ?? 0;
    final limit = user?.dailyMessagesLimit ?? 50;
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    return Column(children: [
      // Profile card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF4))),
        child: Column(children: [
          Row(children: [
            _Avatar(user: user, radius: 26),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.username ?? 'User',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF12112A))),
              if (user?.isPremium == true)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.workspace_premium_rounded,
                        size: 11, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text('Premium',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFD97706),
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
            ]),
          ]),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEAEAF4)),
          const SizedBox(height: 12),
          // Usage
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Daily Usage',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF12112A))),
            Text('$used / $limit',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C63FF))),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFEEEDFF),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
              )),
          const SizedBox(height: 6),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Resets in 24 hours',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFF7B7A8E)))),
        ]),
      ),

      const SizedBox(height: 14),

      // Tips
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tips for you',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: const Color(0xFF12112A))),
          const SizedBox(height: 14),
          _tip(Icons.mic_rounded, const Color(0xFF8B5CF6), 'Try voice input',
              'Faster than typing'),
          const SizedBox(height: 12),
          _tip(Icons.image_rounded, const Color(0xFF3B82F6),
              'Clear images work best', 'Higher quality = better insights'),
          const SizedBox(height: 12),
          _tip(Icons.bookmark_rounded, const Color(0xFF6C63FF),
              'Bookmark key chats', 'Save important conversations'),
        ]),
      ),
    ]);
  }

  Widget _tip(IconData icon, Color color, String t, String s) => Row(children: [
        Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 17)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF12112A))),
          Text(s,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: const Color(0xFF7B7A8E))),
        ])),
      ]);
}

// ── Mobile usage mini card ────────────────────────────────────────
class _UsageMini extends StatelessWidget {
  final dynamic user;
  final VoidCallback onUpgrade;
  const _UsageMini({required this.user, required this.onUpgrade});

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
          border: Border.all(color: const Color(0xFFEAEAF4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Daily Usage',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF12112A))),
          GestureDetector(
              onTap: onUpgrade,
              child: Text('Upgrade ↗',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C63FF)))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEEDFF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
            )),
        const SizedBox(height: 8),
        Text('$used of $limit messages used today',
            style: GoogleFonts.poppins(
                fontSize: 12, color: const Color(0xFF7B7A8E))),
      ]),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int selected;
  final ValueChanged<int> onTap;
  final dynamic user;
  final VoidCallback onUpgrade;
  const _Sidebar(
      {required this.items,
      required this.selected,
      required this.onTap,
      required this.user,
      required this.onUpgrade});

  static const _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFEAEAF4))),
      ),
      child: Column(children: [
        // Logo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/smartai.png',
                  width: 42, height: 42, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: 'Smart',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF12112A))),
                TextSpan(
                    text: 'AI',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _primary)),
              ])),
              Text('Your AI Assistant',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: const Color(0xFF7B7A8E))),
            ]),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFEAEAF4)),
        const SizedBox(height: 10),

        // Nav items
        Expanded(
            child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            final sel = selected == i;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: sel
                        ? _primary.withValues(alpha: 0.09)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(item.icon,
                        size: 19,
                        color: sel ? _primary : const Color(0xFF7B7A8E)),
                    const SizedBox(width: 11),
                    Expanded(
                        child: Text(item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400,
                              color: sel ? _primary : const Color(0xFF374151),
                            ))),
                    if (sel)
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: _primary, shape: BoxShape.circle)),
                  ]),
                ),
              ),
            );
          },
        )),

        const Divider(height: 1, color: Color(0xFFEAEAF4)),

        // Footer links
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(children: [
            _footerItem(
                context,
                Icons.person_outline_rounded,
                'Profile',
                false,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserSettingsScreen()))),
            _footerItem(
                context,
                Icons.settings_outlined,
                'Settings',
                false,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserSettingsScreen()))),
            _footerItem(
                context, Icons.help_outline_rounded, 'Support', false, () {}),
            _footerItem(
                context,
                Icons.logout_rounded,
                'Logout',
                true,
                () => context.read<AuthProvider>().logout().then((_) {
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    })),
          ]),
        ),

        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _footerItem(BuildContext ctx, IconData icon, String label, bool red,
      VoidCallback onTap) {
    final color = red ? const Color(0xFFEF4444) : const Color(0xFF6B7280);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
          child: Row(children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 11),
            Text(label, style: GoogleFonts.poppins(fontSize: 13, color: color)),
          ]),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final dynamic user;
  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFEAEAF4)))),
      child: Row(children: [
        // Search
        Expanded(
            child: Container(
          height: 38,
          decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEAEAF4))),
          child: Row(children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, size: 17, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text('Search anything...',
                style:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400])),
            const Spacer(),
            Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('Ctrl /',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500]))),
          ]),
        )),
        const SizedBox(width: 14),
        _NotifBell(),
        const SizedBox(width: 14),
        _Avatar(user: user, radius: 18),
        const SizedBox(width: 9),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user?.username ?? 'User',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF12112A))),
              if (user?.isPremium == true)
                Text('Premium',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFFD97706),
                        fontWeight: FontWeight.w500)),
            ]),
        Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[400], size: 18),
      ]),
    );
  }
}

// ── Bottom nav (mobile) ───────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selected, required this.onTap});

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.history_rounded, 'History'),
    (Icons.add_rounded, ''),
    (Icons.star_outline_rounded, 'Favorites'),
    (Icons.person_outline_rounded, 'Profile'),
  ];
  static const _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAF4)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final sel = selected == i;
          if (i == 2) {
            return GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ]),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 26)));
          }
          return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.$1,
                            size: 22, color: sel ? _primary : Colors.grey[400]),
                        const SizedBox(height: 3),
                        Text(item.$2,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: sel ? _primary : Colors.grey[400],
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.normal)),
                      ])));
        }).toList(),
      ),
    );
  }
}

// ── Notification bell ─────────────────────────────────────────────
class _NotifBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
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
    ]);
  }
}

// ── Avatar ────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final dynamic user;
  final double radius;
  const _Avatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
      backgroundImage:
          user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
      child: user?.avatarUrl == null
          ? Text(
              user?.username?.isNotEmpty == true
                  ? user!.username[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w700,
                  fontSize: radius * 0.85))
          : null,
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _Feature {
  final String title, subtitle;
  final IconData icon;
  final Color color, bg;
  const _Feature(this.title, this.subtitle, this.icon, this.color, this.bg);
}
