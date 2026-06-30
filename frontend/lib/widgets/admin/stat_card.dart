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
  final bool isPositive;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.growth,
    required this.growthType,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color trendColor =
        isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: D.bd(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: D.isDark(context)
                ? Colors.black.withValues(alpha: 0.18)
                : const Color(0xFF1A1464).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iconColor.withValues(alpha: 0.20),
                        iconColor.withValues(alpha: 0.06)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          isPositive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 10,
                          color: trendColor),
                      const SizedBox(width: 2),
                      Text(growth,
                          style: GoogleFonts.poppins(
                              color: trendColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: D.t1(context),
                  letterSpacing: -0.6),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  color: D.t2(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              growthType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: D.t3(context), fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}
