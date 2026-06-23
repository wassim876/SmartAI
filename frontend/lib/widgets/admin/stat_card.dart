import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String growth;
  final String growthType;
  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.growth,
    required this.growthType,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: D.bd(context), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(children: [
                        const Icon(Icons.arrow_upward, size: 10, color: Colors.green),
                        const SizedBox(width: 2),
                        Text(growth, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    const SizedBox(width: 6),
                    Flexible(child: Text(growthType, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: D.t3(context), fontSize: 10))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
