import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/dark_mode_helpers.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
                    Text('Reports', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Generate and download platform reports', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text('Generate', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
              final aspectRatio = constraints.maxWidth > 700 ? 1.3 : 1.1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: aspectRatio,
                children: [
                  _reportTypeCard(context, Icons.people_outline_rounded, const Color(0xFF3B82F6), 'User Activity', 'User growth, engagement & retention'),
                  _reportTypeCard(context, Icons.attach_money_rounded, const Color(0xFF10B981), 'Revenue', 'Income, subscriptions & refunds'),
                  _reportTypeCard(context, Icons.smart_toy_outlined, const Color(0xFF8B5CF6), 'AI Usage', 'Service usage by type & volume'),
                  _reportTypeCard(context, Icons.security_outlined, const Color(0xFFF59E0B), 'System Health', 'Uptime, errors & performance'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          Container(
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
                  child: Text('Recent Reports', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
                ),
                Divider(height: 1, color: D.divider(context)),
                LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return _buildTable(context);
                  } else {
                    return _buildCardList(context);
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: _headerCell(context, 'REPORT NAME')),
              Expanded(flex: 2, child: _headerCell(context, 'TYPE')),
              Expanded(flex: 2, child: _headerCell(context, 'GENERATED')),
              Expanded(flex: 1, child: _headerCell(context, 'FORMAT')),
              Expanded(flex: 1, child: _headerCell(context, 'ACTIONS')),
            ],
          ),
        ),
        Divider(height: 1, color: D.divider(context)),
        _buildReportRow(context, 'Monthly User Growth - May 2024', 'User Activity', 'Jun 1, 2024', 'PDF'),
        _buildReportRow(context, 'Revenue Summary - Q2 2024', 'Revenue', 'Jun 5, 2024', 'XLSX'),
        _buildReportRow(context, 'AI Services Usage - May 2024', 'AI Usage', 'Jun 2, 2024', 'CSV'),
        _buildReportRow(context, 'System Uptime Report - May 2024', 'System Health', 'Jun 1, 2024', 'PDF'),
      ],
    );
  }

  Widget _buildCardList(BuildContext context) {
    final reports = [
      ('Monthly User Growth - May 2024', 'User Activity', 'Jun 1, 2024', 'PDF'),
      ('Revenue Summary - Q2 2024', 'Revenue', 'Jun 5, 2024', 'XLSX'),
      ('AI Services Usage - May 2024', 'AI Usage', 'Jun 2, 2024', 'CSV'),
      ('System Uptime Report - May 2024', 'System Health', 'Jun 1, 2024', 'PDF'),
    ];

    return Column(
      children: reports.map((r) {
        final (name, type, date, format) = r;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: D.t1(context))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(child: Text(type, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12), overflow: TextOverflow.ellipsis)),
                            Text(' · ', style: TextStyle(color: D.t3(context))),
                            Flexible(child: Text(date, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: D.hover(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(format, style: GoogleFonts.poppins(color: D.t1(context), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.download_outlined, size: 18, color: D.t3(context)),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: D.divider(context)),
          ],
        );
      }).toList(),
    );
  }

  Widget _headerCell(BuildContext context, String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: D.t2(context), letterSpacing: 0.5));
  }

  Widget _reportTypeCard(BuildContext context, IconData icon, Color color, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: D.bd(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: D.t1(context))),
          const SizedBox(height: 3),
          Text(description, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildReportRow(BuildContext context, String name, String type, String date, String format) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: D.t1(context)))),
          Expanded(flex: 2, child: Text(type, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 13))),
          Expanded(flex: 2, child: Text(date, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 13))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: D.hover(context), borderRadius: BorderRadius.circular(8)),
              child: Text(format, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: D.t1(context), fontSize: 11, fontWeight: FontWeight.w500)),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.download_outlined, size: 18, color: D.t3(context)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
