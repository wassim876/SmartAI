import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/dark_mode_helpers.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<_HistoryItem> _historyItems = [];
  bool _isLoading = true;

  static const _primary = Color(0xFF5B4FE8);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final authProvider = context.read<AuthProvider>();
    final activities = authProvider.activities;

    if (activities.isNotEmpty) {
      _historyItems = activities.map((activity) {
        final action = activity['action'] ?? 'Unknown';
        final details = activity['details'] ?? {};
        final createdAtRaw = activity['created_at'];
        DateTime createdAt;
        if (createdAtRaw is DateTime) {
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
            subtitle = details['message']?.toString() ?? 'New chat';
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
          case 'login':
          case 'google_login':
          case 'github_login':
            icon = Icons.login_rounded;
            color = Colors.green;
            title = 'Login';
            subtitle = action.replaceAll('_', ' ').toUpperCase();
            break;
          case 'signup':
            icon = Icons.person_add_rounded;
            color = Colors.blue;
            title = 'Account Created';
            subtitle = 'New user registration';
            break;
          default:
            icon = Icons.fiber_manual_record_rounded;
            color = Colors.grey;
            title = action.replaceAll('_', ' ').toUpperCase();
            subtitle = '';
        }

        return _HistoryItem(
          id: activity['id']?.toString() ?? '',
          title: title,
          subtitle: subtitle,
          icon: icon,
          color: color,
          timeAgo: _formatTimeAgo(createdAt),
        );
      }).toList();
    }

    setState(() => _isLoading = false);
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: D.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear History',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: D.t1(context))),
        content: Text('Delete all activity history? This cannot be undone.',
            style: GoogleFonts.poppins(fontSize: 14, color: D.t2(context))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: D.t2(context)))),
          ElevatedButton(
            onPressed: () {
              setState(() => _historyItems.clear());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('Delete All',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: D.bg(context),
      appBar: AppBar(
        backgroundColor: D.appBar(context),
        elevation: 0,
        centerTitle: true,
        leading: !canPop
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: D.t1(context)),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text('Activity History',
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: D.t1(context))),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: D.t2(context)),
                onPressed: _showClearDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _historyItems.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _buildItem(i),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
              color: D.bd(context), borderRadius: BorderRadius.circular(20)),
          child:
              Icon(Icons.history_rounded, size: 36, color: D.t2(context))),
      const SizedBox(height: 16),
      Text('No history yet',
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: D.t1(context))),
      const SizedBox(height: 6),
      Text('Your recent activities will appear here',
          style: GoogleFonts.poppins(fontSize: 13, color: D.t2(context))),
    ]));
  }

  Widget _buildItem(int index) {
    final item = _historyItems[index];
    return Dismissible(
      key: ValueKey('history_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        final title = item.title;
        setState(() => _historyItems.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$title removed'),
            behavior: SnackBarBehavior.floating));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: D.t1(context))),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: D.t2(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item.timeAgo,
                style:
                    GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
            const SizedBox(height: 4),
            Icon(Icons.chevron_right_rounded,
                color: D.t2(context), size: 18),
          ]),
        ]),
      ),
    );
  }
}

class _HistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String timeAgo;

  _HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.timeAgo,
  });
}
