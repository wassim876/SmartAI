import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/dark_mode_helpers.dart';
import '../../../services/supabase_data_service.dart';

/// Reports — generate and download real CSV exports of the platform's data.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _accent = Color(0xFF6C63FF);

  final _data = SupabaseDataService();
  final List<_Report> _recent = [];
  String? _busyKey; // which report type is currently generating

  static const List<_ReportType> _types = [
    _ReportType('users', 'Users', 'Accounts, roles & usage', 'users_report',
        Icons.people_outline_rounded, Color(0xFF3B82F6)),
    _ReportType('ai', 'AI Usage', 'Requests by service', 'ai_usage_report',
        Icons.smart_toy_outlined, Color(0xFF8B5CF6)),
    _ReportType('reviews', 'Reviews', 'Ratings & feedback', 'reviews_report',
        Icons.star_outline_rounded, Color(0xFFF59E0B)),
    _ReportType('activity', 'Activity Log', 'Sign-ins & actions',
        'activity_report', Icons.history_rounded, Color(0xFF10B981)),
  ];

  // ---------------- data ----------------
  Future<List<Map<String, dynamic>>> _fetch(String key) {
    switch (key) {
      case 'users':
        return _data.reportUsers();
      case 'ai':
        return _data.reportAiUsage();
      case 'reviews':
        return _data.reportReviews();
      case 'activity':
        return _data.reportActivity();
      default:
        return Future.value(const []);
    }
  }

  Future<void> _generate(_ReportType type) async {
    if (_busyKey != null) return;
    setState(() => _busyKey = type.key);
    try {
      final rows = await _fetch(type.key);
      if (rows.isEmpty) {
        _snack('No data to export for ${type.title}.');
        return;
      }
      final bytes = Uint8List.fromList(utf8.encode(_toCsv(rows)));
      final now = DateTime.now();
      final fileName =
          '${type.fileBase}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
      final saved = await _save(fileName, bytes);
      if (saved == null) return; // cancelled
      setState(() {
        _recent.insert(
            0,
            _Report(
              name: '${type.title} — ${DateFormat('MMM d, yyyy').format(now)}',
              type: type.title,
              at: now,
              rowCount: rows.length,
              bytes: bytes,
              fileBase: type.fileBase,
            ));
      });
      _snack('Saved ${type.title} report (${rows.length} rows).');
    } catch (e) {
      _snack('Could not generate report: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<String?> _save(String fileName, Uint8List bytes) async {
    // On web there is no filesystem: passing `bytes` makes file_picker trigger
    // a browser download directly (it returns null but the download happens).
    if (kIsWeb) {
      await FilePicker.platform.saveFile(
        dialogTitle: 'Save report',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        bytes: bytes,
      );
      return fileName;
    }
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save report',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    if (path == null) return null;
    final out = path.toLowerCase().endsWith('.csv') ? path : '$path.csv';
    await File(out).writeAsBytes(bytes, flush: true);
    return out;
  }

  Future<void> _redownload(_Report r) async {
    final fileName =
        '${r.fileBase}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    try {
      final saved = await _save(fileName, r.bytes);
      if (saved != null) _snack('Saved ${r.type} report.');
    } catch (_) {
      _snack('Could not save report.');
    }
  }

  String _toCsv(List<Map<String, dynamic>> rows) {
    final cols = <String>{};
    for (final r in rows) {
      cols.addAll(r.keys);
    }
    final headers = cols.toList();
    final buf = StringBuffer()..writeln(headers.map(_esc).join(','));
    for (final r in rows) {
      buf.writeln(headers.map((h) => _esc(r[h])).join(','));
    }
    return buf.toString();
  }

  String _esc(dynamic v) {
    if (v == null) return '';
    var s = (v is Map || v is List) ? jsonEncode(v) : v.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      s = '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  void _openGenerateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: D.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Generate a report',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: D.t1(context))),
              ),
            ),
            for (final t in _types)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: t.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(t.icon, color: t.color, size: 20),
                ),
                title: Text(t.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: D.t1(context))),
                subtitle: Text('${t.description}  ·  CSV',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: D.t2(context))),
                onTap: () {
                  Navigator.pop(ctx);
                  _generate(t);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reports',
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: D.t1(context),
                            letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Generate and download platform reports as CSV',
                        style: GoogleFonts.poppins(
                            color: D.t2(context), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _busyKey != null ? null : _openGenerateSheet,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text('Generate',
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, c) {
              final cross = c.maxWidth > 900 ? 4 : (c.maxWidth > 560 ? 2 : 1);
              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.55,
                children: [for (final t in _types) _typeCard(t)],
              );
            },
          ),
          const SizedBox(height: 24),
          _recentPanel(),
        ],
      ),
    );
  }

  Widget _typeCard(_ReportType t) {
    final busy = _busyKey == t.key;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _busyKey != null ? null : () => _generate(t),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: D.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: D.bd(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(t.icon, color: t.color, size: 22),
                  ),
                  const Spacer(),
                  if (busy)
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Icon(Icons.download_rounded, size: 16, color: D.t3(context)),
                ],
              ),
              const Spacer(),
              Text(t.title,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: D.t1(context))),
              const SizedBox(height: 3),
              Text(t.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      GoogleFonts.poppins(color: D.t2(context), fontSize: 11.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentPanel() {
    return Container(
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: D.bd(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Text('Recent reports (this session)',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: D.t1(context))),
          ),
          Divider(height: 1, color: D.divider(context)),
          if (_recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 30, color: D.t3(context)),
                    const SizedBox(height: 8),
                    Text('No reports generated yet',
                        style: GoogleFonts.poppins(
                            color: D.t2(context), fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Tap a report type above, or use Generate.',
                        style: GoogleFonts.poppins(
                            color: D.t3(context), fontSize: 11.5)),
                  ],
                ),
              ),
            )
          else
            for (int i = 0; i < _recent.length; i++) ...[
              _recentRow(_recent[i]),
              if (i != _recent.length - 1)
                Divider(height: 1, color: D.divider(context)),
            ],
        ],
      ),
    );
  }

  Widget _recentRow(_Report r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: D.t1(context))),
                const SizedBox(height: 3),
                Text(
                    '${r.type}  ·  ${r.rowCount} rows  ·  ${DateFormat('MMM d, HH:mm').format(r.at)}',
                    style: GoogleFonts.poppins(
                        color: D.t2(context), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: D.hover(context),
                borderRadius: BorderRadius.circular(8)),
            child: Text('CSV',
                style: GoogleFonts.poppins(
                    color: D.t1(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.download_outlined, size: 18, color: D.t2(context)),
            tooltip: 'Save again',
            onPressed: () => _redownload(r),
          ),
        ],
      ),
    );
  }
}

class _ReportType {
  final String key;
  final String title;
  final String description;
  final String fileBase;
  final IconData icon;
  final Color color;
  const _ReportType(this.key, this.title, this.description, this.fileBase,
      this.icon, this.color);
}

class _Report {
  final String name;
  final String type;
  final DateTime at;
  final int rowCount;
  final Uint8List bytes;
  final String fileBase;
  _Report({
    required this.name,
    required this.type,
    required this.at,
    required this.rowCount,
    required this.bytes,
    required this.fileBase,
  });
}
