import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/activity_tile.dart';
import 'chat_screen.dart';
import 'user_settings_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';
import '../../theme/dark_mode_helpers.dart';

const _primary = Color(0xFF6C63FF);

Color _text1(BuildContext c) => D.t1(c);
Color _text2(BuildContext c) => D.t2(c);
Color _border(BuildContext c) => D.bd(c);

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _Feature {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final bool interactive;
  const _Feature(this.title, this.subtitle, this.icon, this.color,
      {this.interactive = true});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.auto_awesome_rounded, 'AI Chat'),
    _NavItem(Icons.history_rounded, 'History'),
    _NavItem(Icons.star_outline_rounded, 'Favorites'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchAllUserData();
    });
  }

  void _navigate(int i) {
    switch (i) {
      case 1:
        Navigator.push(context, _route(const ChatScreen()));
        break;
      case 2:
        Navigator.pushNamed(context, '/history');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorites coming soon!')));
        break;
      default:
        setState(() => _selectedIndex = i);
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
                  'Priority support'
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
                        elevation: 0),
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

  Widget _wide() {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: D.bg(context),
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
          Expanded(child: _content(wide: true))
        ])),
      ]),
    );
  }

  Widget _mobile() {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: D.bg(context),
      appBar: _buildMobileAppBar(user),
      drawer: _MobileDrawer(user: user),
      body: _content(wide: false),
      bottomNavigationBar: _BottomNav(
        selected: _selectedIndex,
        onTap: (i) {
          if (i == 4) {
            Navigator.push(context, _route(const UserSettingsScreen()));
          } else if (i == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (i == 2) {
            Navigator.push(context, _route(const ChatScreen()));
          } else if (i == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites coming soon!')));
          } else {
            setState(() => _selectedIndex = i);
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(dynamic user) {
    return AppBar(
      backgroundColor: D.appBar(context),
      elevation: 0,
      titleSpacing: 18,
      title: Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/smartai.png',
                width: 44, height: 44, fit: BoxFit.cover)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Smart',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _text1(context))),
            TextSpan(
                text: 'AI',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _primary)),
          ])),
          Text('Your AI Assistant',
              style: GoogleFonts.poppins(fontSize: 10, color: _text2(context))),
        ]),
      ]),
      actions: [
        _LangPicker(),
        _NotifBell(),
        const SizedBox(width: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.push(context, _route(const ProfileScreen())),
            child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _Avatar(user: user, radius: 19)),
          ),
        ),
      ],
    );
  }

  Widget _content({required bool wide}) {
    final user = context.watch<AuthProvider>().currentUser;
    final authProvider = context.watch<AuthProvider>();
    final chatCount = authProvider.chatHistory.length;
    final imageCount = authProvider.imageAnalyses.length;
    final activityCount = authProvider.activities.length;
    final loc = AppLocalizations.of(context);
    final cols = wide ? 3 : 2;

    final features = [
      _Feature(loc.translate('aiChat'), loc.translate('aiChatDesc'),
          Icons.auto_awesome_rounded, const Color(0xFF6366F1)),
      _Feature('Code Assistant', 'Write & debug code', Icons.code_rounded,
          const Color(0xFF10B981)),
      _Feature('Writing Assistant', 'Essays, emails & more',
          Icons.edit_note_rounded, const Color(0xFFF59E0B)),
      _Feature('Image Analysis', 'Analyze photos & pictures',
          Icons.image_search_rounded, const Color(0xFF3B82F6)),
      _Feature('Translator', 'Translate any language', Icons.translate_rounded,
          const Color(0xFFEC4899)),
      _Feature('Summarizer', 'Summarize long texts', Icons.summarize_rounded,
          const Color(0xFF8B5CF6),
          interactive: false),
    ];

    final prompts = [
      '',
      'Help me write and debug code. ',
      'Help me write ',
      '',
      'Translate the following to English: ',
      'Summarize the following text: ',
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          wide ? 32 : 18, wide ? 28 : 20, wide ? 32 : 18, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _HeroGreeting(user: user, wide: wide),
        SizedBox(height: wide ? 32 : 22),
        if (wide) ...[
          _QuickStats(
              chatCount: chatCount,
              imageCount: imageCount,
              activityCount: activityCount),
          const SizedBox(height: 28),
        ],
        _SectionLabel(
            title: loc.translate('aiFeatures'),
            subtitle: loc.translate('chooseTool')),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: wide ? 1.6 : 0.85),
          itemCount: features.length,
          itemBuilder: (_, i) {
            final f = features[i];
            return _FeatureCard(
                feature: f,
                locked: false,
                wide: wide, // Always interactive now
                onTap: () {
                  Navigator.push(
                      context, _route(ChatScreen(initialPrompt: prompts[i])));
                });
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

class _HeroGreeting extends StatelessWidget {
  final dynamic user;
  final bool wide;
  const _HeroGreeting({required this.user, required this.wide});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 28 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10))
        ],
      ),
      child: Stack(children: [
        Positioned(
            top: -30,
            right: -20,
            child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08)))),
        Positioned(
            bottom: -40,
            right: wide ? 60 : 20,
            child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06)))),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    '${loc.translate('hello')}, ${user?.displayName ?? 'User'}! 👋',
                    style: GoogleFonts.poppins(
                        fontSize: wide ? 26 : 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text(loc.translate('welcomeBack'),
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.white70, height: 1.5)),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _HeroPill(
                      icon: Icons.auto_awesome_rounded,
                      label: loc.translate('aiPowered'),
                      color: const Color(0xFFEC4899)),
                  _HeroPill(
                      icon: Icons.bolt_rounded,
                      label: loc.translate('instantResults'),
                      color: const Color(0xFF06B6D4)),
                ]),
              ])),
          if (wide) ...[
            const SizedBox(width: 20),
            Image.asset('assets/images/home_ai.png', width: 90, height: 90)
          ],
        ]),
      ]),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HeroPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
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

class _QuickStats extends StatelessWidget {
  final int chatCount, imageCount, activityCount;
  const _QuickStats(
      {required this.chatCount,
      required this.imageCount,
      required this.activityCount});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        chatCount.toString(),
        'AI Chats',
        Icons.chat_bubble_rounded,
        const Color(0xFF6366F1),
        const Color(0xFF818CF8)
      ),
      (
        imageCount.toString(),
        'Images',
        Icons.image_rounded,
        const Color(0xFF06B6D4),
        const Color(0xFF22D3EE)
      ),
      (
        activityCount.toString(),
        'Activities',
        Icons.history_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFBBF24)
      ),
    ];
    return Row(
        children: stats
            .map((s) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: s == stats.last ? 0 : 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [s.$4, s.$5],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: s.$4.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10)),
                                child:
                                    Icon(s.$3, color: Colors.white, size: 18)),
                            const SizedBox(height: 12),
                            Text(s.$1,
                                style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(s.$2,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        Colors.white.withValues(alpha: 0.85))),
                          ]),
                    ),
                  ),
                ))
            .toList());
  }
}

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
                    color: _text1(context))),
            Text(subtitle,
                style:
                    GoogleFonts.poppins(fontSize: 12, color: _text2(context))),
          ]),
        ]);
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final bool locked, wide;
  final VoidCallback? onTap;
  const _FeatureCard(
      {required this.feature,
      required this.locked,
      required this.wide,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: locked
                ? _border(context)
                : feature.color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: feature.color.withValues(alpha: locked ? 0.03 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: wide ? _wideContent(context) : _mobileContent(context),
    );

    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }

  Widget _wideContent(BuildContext context) => Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  feature.color,
                  feature.color.withValues(alpha: 0.7)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: feature.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]),
            child: Icon(feature.icon, color: Colors.white, size: 24)),
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
                            color: _text1(context)))),
                if (locked)
                  const Icon(Icons.lock_rounded,
                      size: 14, color: Color(0xFFB0B0C8)),
              ]),
              const SizedBox(height: 3),
              Text(feature.subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: _text2(context), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ])),
      ]);

  Widget _mobileContent(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    feature.color,
                    feature.color.withValues(alpha: 0.7)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        color: feature.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]),
              child: Icon(feature.icon, color: Colors.white, size: 22)),
          if (locked)
            const Icon(Icons.lock_rounded, size: 14, color: Color(0xFFB0B0C8)),
        ]),
        const Spacer(),
        Text(feature.title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _text1(context))),
        const SizedBox(height: 3),
        Text(feature.subtitle,
            style: GoogleFonts.poppins(
                fontSize: 10, color: _text2(context), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        if (onTap != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                gradient: locked
                    ? null
                    : LinearGradient(colors: [
                        feature.color,
                        feature.color.withValues(alpha: 0.8)
                      ]),
                color: locked ? const Color(0xFFF0F0F8) : null,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(locked ? '🔒 Upgrade' : 'Open',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            locked ? const Color(0xFFB0B0C8) : Colors.white))),
          ),
        ],
      ]);
}

class _ActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final activities = authProvider.activities;
    final recentActivities =
        activities.length > 3 ? activities.sublist(0, 3) : activities;
    final loc = AppLocalizations.of(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.translate('recentActivity'),
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _text1(context))),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/history'),
              child: Text(loc.translate('viewAll'),
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primary))),
        ),
      ]),
      const SizedBox(height: 12),
      if (recentActivities.isEmpty)
        _buildEmptyActivity(context)
      else
        ...recentActivities
            .map((activity) => _buildActivityTile(context, activity)),
    ]);
  }

  Widget _buildEmptyActivity(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
          color: D.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border(context))),
      child: Column(children: [
        Icon(Icons.inbox_rounded, size: 40, color: D.t2(context)),
        const SizedBox(height: 8),
        Text(loc.translate('noActivities'),
            style: GoogleFonts.poppins(fontSize: 14, color: D.t2(context))),
        Text(loc.translate('noActivitiesHint'),
            style: GoogleFonts.poppins(fontSize: 12, color: D.t2(context))),
      ]),
    );
  }

  Widget _buildActivityTile(
      BuildContext context, Map<String, dynamic> activity) {
    final action = activity['action'] ?? 'Unknown';
    final details = activity['details'] ?? {};
    final createdAtRaw = activity['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw != null) {
      createdAt = DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    late IconData icon;
    late Color color;
    late String title;
    late String subtitle;

    switch (action) {
      case 'chat_message':
        icon = Icons.auto_awesome_rounded;
        color = _primary;
        title = 'Chat with AI';
        final msg = details['message']?.toString() ?? '';
        subtitle = msg.length > 30 ? '${msg.substring(0, 30)}...' : msg;
        break;
      case 'image_analysis':
        icon = Icons.image_search_rounded;
        color = const Color(0xFF3B82F6);
        title = 'Image Analysis';
        subtitle = details['image_type'] ?? 'Image analyzed';
        break;
      case 'speech_to_text':
        icon = Icons.mic_rounded;
        color = const Color(0xFF8B5CF6);
        title = 'Speech to Text';
        subtitle = 'Voice transcribed';
        break;
      default:
        icon = Icons.fiber_manual_record_rounded;
        color = Colors.grey;
        title = action.replaceAll('_', ' ').toUpperCase();
        subtitle = '';
    }

    return ActivityTile(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle.isNotEmpty ? subtitle : _formatDate(createdAt),
      time: _formatTime(createdAt),
      onTap: () {
        switch (action) {
          case 'chat_message':
          case 'image_analysis':
          case 'speech_to_text':
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            break;
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _RightPanel extends StatelessWidget {
  final dynamic user;
  const _RightPanel({required this.user});

  @override
  Widget build(BuildContext context) {
    final used = user?.dailyMessagesUsed ?? 0;
    final limit = user?.dailyMessagesLimit ?? 50;
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    return Column(children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: D.card(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border(context))),
        child: Column(children: [
          Row(children: [
            _Avatar(user: user, radius: 26),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.displayName ?? 'User',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _text1(context))),
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
                              fontWeight: FontWeight.w600))
                    ])),
            ]),
          ]),
          const SizedBox(height: 16),
          Divider(color: _border(context)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Daily Usage',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _text1(context))),
            Text('$used / $limit',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFEEEDFF),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)))),
          const SizedBox(height: 6),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Resets in 24 hours',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: _text2(context)))),
        ]),
      ),
      const SizedBox(height: 14),
      Builder(builder: (context) {
        final loc = AppLocalizations.of(context);
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: D.card(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border(context))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loc.translate('tipsForYou'),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _text1(context))),
            const SizedBox(height: 14),
            _buildTip(context, Icons.mic_rounded, const Color(0xFF8B5CF6),
                loc.translate('tryVoice'), loc.translate('tryVoiceHint')),
            const SizedBox(height: 12),
            _buildTip(context, Icons.image_rounded, const Color(0xFF3B82F6),
                loc.translate('clearImages'), loc.translate('clearImagesHint')),
            const SizedBox(height: 12),
            _buildTip(
                context,
                Icons.bookmark_rounded,
                const Color(0xFF6C63FF),
                loc.translate('bookmarkChats'),
                loc.translate('bookmarkChatsHint')),
          ]),
        );
      }),
    ]);
  }

  Widget _buildTip(BuildContext context, IconData icon, Color color,
      String title, String subtitle) {
    return Row(children: [
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
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _text1(context))),
        Text(subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: _text2(context))),
      ])),
    ]);
  }
}

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
          color: D.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(context))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Daily Usage',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _text1(context))),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: onUpgrade,
                child: Text('Upgrade ↗',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primary))),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFEEEDFF),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)))),
        const SizedBox(height: 8),
        Text('$used of $limit messages used today',
            style: GoogleFonts.poppins(fontSize: 12, color: _text2(context))),
      ]),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
          color: D.card(context),
          border: Border(right: BorderSide(color: _border(context)))),
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/smartai.png',
                      width: 42, height: 42, fit: BoxFit.cover)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Smart',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _text1(context))),
                  TextSpan(
                      text: 'AI',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ])),
                Text('Your AI Assistant',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: _text2(context))),
              ]),
            ])),
        Divider(height: 1, color: _border(context)),
        const SizedBox(height: 10),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                        color: sel
                            ? _primary.withValues(alpha: 0.09)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(item.icon,
                          size: 19, color: sel ? _primary : _text2(context)),
                      const SizedBox(width: 11),
                      Expanded(
                          child: Text(item.label,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      sel ? FontWeight.w600 : FontWeight.w400,
                                  color: sel ? _primary : D.t1(context)))),
                      if (sel)
                        Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: _primary, shape: BoxShape.circle)),
                    ]),
                  ),
                ));
          },
        )),
        Divider(height: 1, color: _border(context)),
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
                          builder: (_) => const ProfileScreen()))),
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
                  context,
                  Icons.info_outline_rounded,
                  'About',
                  false,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()))),
              _footerItem(context, Icons.help_outline_rounded, 'Support', false,
                  () => Navigator.pushNamed(context, '/help')),
              _footerItem(
                  context,
                  Icons.logout_rounded,
                  'Logout',
                  true,
                  () => context.read<AuthProvider>().signOut().then((_) {
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      })),
            ])),
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
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 13, color: color)),
              ])),
        ));
  }
}

class _TopBar extends StatelessWidget {
  final dynamic user;
  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
          color: D.appBar(context),
          border: Border(bottom: BorderSide(color: _border(context)))),
      child: Row(children: [
        Expanded(
            child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _openSearch(context, loc),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                  color: D.bg(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: D.bd(context))),
              child: Row(children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, size: 17, color: D.t2(context)),
                const SizedBox(width: 8),
                Text(loc.translate('searchAnything'),
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: D.t2(context))),
                const Spacer(),
                Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                        color: D.bd(context),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('Ctrl /',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: D.t2(context)))),
              ]),
            ),
          ),
        )),
        const SizedBox(width: 14),
        _LangPicker(),
        _NotifBell(),
        const SizedBox(width: 14),
        PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) {
            if (val == 'profile') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
            } else if (val == 'settings') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserSettingsScreen()));
            } else if (val == 'about') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()));
            } else if (val == 'support') {
              Navigator.pushNamed(context, '/help');
            } else if (val == 'logout') {
              context.read<AuthProvider>().signOut().then((_) {
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              });
            }
          },
          itemBuilder: (ctx) => [
            _buildPopupItem(
                context, 'profile', Icons.person_outline_rounded, 'Profile'),
            _buildPopupItem(
                context, 'settings', Icons.settings_outlined, 'Settings'),
            _buildPopupItem(
                context, 'about', Icons.info_outline_rounded, 'About'),
            _buildPopupItem(
                context, 'support', Icons.help_outline_rounded, 'Support'),
            const PopupMenuDivider(),
            _buildPopupItem(context, 'logout', Icons.logout_rounded, 'Logout',
                color: Colors.red),
          ],
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(children: [
              _Avatar(user: user, radius: 18),
              const SizedBox(width: 9),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user?.displayName ?? 'User',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _text1(context))),
                    if (user?.isPremium == true)
                      Text('Premium',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFFD97706),
                              fontWeight: FontWeight.w500)),
                  ]),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: D.t2(context), size: 18),
            ]),
          ),
        ),
      ]),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
      BuildContext context, String val, IconData icon, String label,
      {Color? color}) {
    return PopupMenuItem(
        value: val,
        child: Row(children: [
          Icon(icon, size: 18, color: color ?? _text1(context)),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: color ?? _text1(context))),
        ]));
  }

  void _openSearch(BuildContext context, AppLocalizations loc) {
    final items = [
      (
        loc.translate('aiChat'),
        Icons.auto_awesome_rounded,
        const Color(0xFF6366F1),
        'chat'
      ),
      (
        loc.translate('imageAnalysis'),
        Icons.image_search_rounded,
        const Color(0xFF3B82F6),
        'image'
      ),
      (
        loc.translate('speechToText'),
        Icons.mic_rounded,
        const Color(0xFF8B5CF6),
        'speech'
      ),
      (
        loc.translate('history'),
        Icons.history_rounded,
        const Color(0xFFF59E0B),
        'history'
      ),
      (
        loc.translate('profile'),
        Icons.person_outline_rounded,
        const Color(0xFF6366F1),
        'profile'
      ),
      (
        loc.translate('settings'),
        Icons.settings_outlined,
        const Color(0xFF6B7280),
        'settings'
      ),
      (
        loc.translate('about'),
        Icons.info_outline_rounded,
        const Color(0xFF06B6D4),
        'about'
      ),
      (
        loc.translate('helpCenter'),
        Icons.help_outline_rounded,
        const Color(0xFF8B5CF6),
        'help'
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) {
          final controller = TextEditingController();
          var filtered = List.of(items);
          return StatefulBuilder(builder: (ctx, setModalState) {
            return SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(children: [
                Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: D.t2(context),
                        borderRadius: BorderRadius.circular(2))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: D.t1(context)),
                      decoration: InputDecoration(
                          hintText: loc.translate('searchAnything'),
                          hintStyle: GoogleFonts.poppins(
                              color: D.t2(context), fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded,
                              size: 20, color: D.t2(context)),
                          filled: true,
                          fillColor: D.bg(context),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none)),
                      onChanged: (val) {
                        final q = val.toLowerCase();
                        setModalState(() {
                          filtered = items
                              .where(
                                  (item) => item.$1.toLowerCase().contains(q))
                              .toList();
                        });
                      },
                    )),
                const SizedBox(height: 8),
                Expanded(
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          return ListTile(
                            leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: item.$3.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(item.$2, color: item.$3, size: 20)),
                            title: Text(item.$1,
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: _text1(context))),
                            trailing: Icon(Icons.chevron_right_rounded,
                                size: 20, color: _text2(context)),
                            onTap: () {
                              Navigator.pop(ctx);
                              switch (item.$4) {
                                case 'chat':
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const ChatScreen()));
                                  break;
                                case 'image':
                                case 'speech':
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const ChatScreen()));
                                  break;
                                default:
                                  Navigator.pushNamed(context, '/${item.$4}');
                                  break;
                              }
                            },
                          );
                        })),
              ]),
            ));
          });
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selected, required this.onTap});

  static const List<(IconData, String)> _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.history_rounded, 'History'),
    (Icons.add_rounded, ''),
    (Icons.star_outline_rounded, 'Favorites'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
          color: D.appBar(context),
          border: Border(top: BorderSide(color: _border(context)))),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final sel = selected == i;
            if (i == 2) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
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
                            color: Colors.white, size: 26))),
              );
            }
            return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.$1,
                            size: 22, color: sel ? _primary : D.t2(context)),
                        const SizedBox(height: 3),
                        Text(item.$2,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: sel ? _primary : D.t2(context),
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.normal)),
                      ]),
                ));
          }).toList()),
    );
  }
}

class _NotifBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Stack(alignment: Alignment.topRight, children: [
      IconButton(
          icon: Icon(Icons.notifications_outlined, color: D.t2(context)),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (ctx) => SafeArea(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: D.t2(context),
                          borderRadius: BorderRadius.circular(2))),
                  Text(loc.translate('notifications'),
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: D.t1(context))),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: D.bg(context),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Icon(Icons.notifications_none_rounded,
                          size: 48, color: D.t2(context)),
                      const SizedBox(height: 12),
                      Text(loc.translate('noNotifications'),
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _text1(context))),
                      const SizedBox(height: 4),
                      Text(loc.translate('noNotificationsHint'),
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: _text2(context))),
                    ]),
                  ),
                ]),
              )),
            );
          }),
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

class _LangPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final currentCode = langProvider.locale.languageCode;
    final flag = LanguageProvider.languageFlags[currentCode] ?? '🌐';
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (ctx) => DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.75,
                expand: false,
                builder: (ctx, scrollController) => SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(children: [
                    Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                            color: D.t2(context),
                            borderRadius: BorderRadius.circular(2))),
                    Text(AppLocalizations.of(context).translate('language'),
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _text1(context))),
                    const SizedBox(height: 8),
                    Expanded(
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount: LanguageProvider.languageNames.length,
                            itemBuilder: (_, i) {
                              final entry = LanguageProvider
                                  .languageNames.entries
                                  .elementAt(i);
                              return ListTile(
                                leading: Text(
                                    LanguageProvider.languageFlags[entry.key] ??
                                        '🌐',
                                    style: const TextStyle(fontSize: 24)),
                                title: Text(entry.value,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: _text1(context))),
                                trailing: currentCode == entry.key
                                    ? const Icon(Icons.check_rounded,
                                        color: _primary)
                                    : null,
                                onTap: () {
                                  langProvider.setLocale(Locale(entry.key));
                                  Navigator.pop(ctx);
                                  // Pop all routes back to /home so every
                                  // screen rebuilds with the new locale
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/home',
                                    (route) => false,
                                  );
                                },
                              );
                            })),
                  ]),
                )),
              ),
            );
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                  child: Text(flag, style: const TextStyle(fontSize: 20)))),
        ));
  }
}

class _Avatar extends StatelessWidget {
  final dynamic user;
  final double radius;
  const _Avatar({required this.user, required this.radius});

  bool get _hasPhoto {
    final url = user?.photoURL;
    return url != null && url.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
        backgroundImage: _hasPhoto ? NetworkImage(user!.photoURL!) : null,
        onBackgroundImageError: _hasPhoto ? (_, __) {} : null,
        child: _hasPhoto
            ? null
            : Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.w700,
                    fontSize: radius * 0.85)),
      ),
    );
  }
}

// ── Mobile drawer ────────────────────────────────────────────────
class _MobileDrawer extends StatelessWidget {
  final dynamic user;
  const _MobileDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: D.card(context),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // ── Profile header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFFA855F7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: -15,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        right: 30,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              backgroundImage: user?.photoURL != null &&
                                      user!.photoURL!.isNotEmpty
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: (user?.photoURL == null ||
                                      user!.photoURL!.isEmpty)
                                  ? Text(
                                      user?.displayName?.isNotEmpty == true
                                          ? user!.displayName[0].toUpperCase()
                                          : 'U',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'User',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (user?.isPremium == true) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.workspace_premium_rounded,
                                            size: 12,
                                            color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text('Premium',
                                            style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Menu items ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _drawerItem(
                        context: context,
                        icon: Icons.person_outline_rounded,
                        color: const Color(0xFF6366F1),
                        label: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileScreen()));
                        },
                      ),
                      _drawerItem(
                        context: context,
                        icon: Icons.settings_outlined,
                        color: const Color(0xFF3B82F6),
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const UserSettingsScreen()));
                        },
                      ),
                      _drawerItem(
                        context: context,
                        icon: Icons.history_rounded,
                        color: const Color(0xFFF59E0B),
                        label: 'History',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/history');
                        },
                      ),
                      _drawerItem(
                        context: context,
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF06B6D4),
                        label: 'About',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AboutScreen()));
                        },
                      ),
                      _drawerItem(
                        context: context,
                        icon: Icons.help_outline_rounded,
                        color: const Color(0xFF8B5CF6),
                        label: 'Support',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/help');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ──
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            context.read<AuthProvider>().signOut().then((_) {
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/');
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded,
                                  color: Color(0xFFEF4444), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Sign Out',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SmartAI v1.0.0',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: D.t1(context),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: D.t2(context), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
