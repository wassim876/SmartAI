import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../models/activity_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<ActivityModel> _historyItems = [];
  bool _isLoading = true;

  static const _primary = Color(0xFF5B4FE8);
  static const _bg = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final data = await _apiService.getHistory();
      if (mounted) {
        setState(() {
          _historyItems = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear History',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Delete all activity history? This cannot be undone.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins())),
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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: !canPop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Color(0xFF1A1A2E)),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text('Activity History',
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E))),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
                icon:
                    Icon(Icons.delete_outline_rounded, color: Colors.grey[600]),
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
              color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
          child:
              Icon(Icons.history_rounded, size: 36, color: Colors.grey[300])),
      const SizedBox(height: 16),
      Text('No history yet',
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E))),
      const SizedBox(height: 6),
      Text('Your recent activities will appear here',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400])),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
                        color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item.timeAgo,
                style:
                    GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
            const SizedBox(height: 4),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[300], size: 18),
          ]),
        ]),
      ),
    );
  }
}
