import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/dark_mode_helpers.dart';

class AIServicesScreen extends StatelessWidget {
  const AIServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 500;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Services', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Manage and monitor all AI-powered services', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14)),
                ],
              );
              final button = MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Add Service', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 16),
                    Align(alignment: Alignment.centerLeft, child: button),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  button,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100 ? 3 : constraints.maxWidth > 700 ? 2 : 1;
              final double childAspectRatio = constraints.maxWidth > 1100 ? 1.4 : constraints.maxWidth > 700 ? 1.2 : 0.85;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildServiceCard(context, icon: Icons.chat_bubble_outline_rounded, color: const Color(0xFF3B82F6), title: 'Chat Assistant', description: 'Conversational AI assistant for general queries', requests: '35,070', usage: 35.6, status: 'Active'),
                  _buildServiceCard(context, icon: Icons.image_outlined, color: const Color(0xFF10B981), title: 'Image Analysis', description: 'Detect objects, text, and content in images', requests: '22,418', usage: 22.8, status: 'Active'),
                  _buildServiceCard(context, icon: Icons.mic_none_outlined, color: const Color(0xFFF59E0B), title: 'Speech to Text', description: 'Transcribe audio recordings into text', requests: '14,996', usage: 15.3, status: 'Active'),
                  _buildServiceCard(context, icon: Icons.record_voice_over_outlined, color: const Color(0xFF8B5CF6), title: 'Text to Speech', description: 'Convert written text into natural speech', requests: '10,520', usage: 10.7, status: 'Active'),
                  _buildServiceCard(context, icon: Icons.translate_outlined, color: const Color(0xFF14B8A6), title: 'Translation', description: 'Translate text between multiple languages', requests: '8,455', usage: 8.6, status: 'Active'),
                  _buildServiceCard(context, icon: Icons.apps_outlined, color: const Color(0xFF6B7280), title: 'Others', description: 'Miscellaneous AI utilities and tools', requests: '5,861', usage: 6.0, status: 'Maintenance'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String requests,
    required double usage,
    required String status,
  }) {
    final bool isActive = status == 'Active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: D.bd(context), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.12) : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: GoogleFonts.poppins(
                  color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: D.t1(context))),
          const SizedBox(height: 4),
          Text(description, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$requests requests', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: D.t1(context))),
              Text('$usage% of total', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: usage / 100,
              minHeight: 6,
              backgroundColor: D.hover(context),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: D.bd(context)),
                      foregroundColor: D.t1(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Configure', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: D.bd(context)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.more_vert_rounded, size: 18, color: D.t2(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
