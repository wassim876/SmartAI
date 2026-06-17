import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsageTracker extends StatelessWidget {
  final int messagesUsed;
  final int messagesLimit;
  final VoidCallback onUpgradeTap;

  const UsageTracker({
    super.key,
    required this.messagesUsed,
    required this.messagesLimit,
    required this.onUpgradeTap,
  });

  static const _primary = Color(0xFF5B4FE8);

  @override
  Widget build(BuildContext context) {
    final progress = messagesLimit > 0
        ? (messagesUsed / messagesLimit).clamp(0.0, 1.0)
        : 0.0;
    final isNearLimit = progress > 0.8;
    final barColor = isNearLimit ? const Color(0xFFEF4444) : _primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isNearLimit ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    isNearLimit
                        ? Icons.warning_rounded
                        : Icons.bar_chart_rounded,
                    color: barColor,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Daily Usage',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ]),
              GestureDetector(
                onTap: onUpgradeTap,
                child: Text(
                  'Upgrade ↗',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: barColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNearLimit ? '⚠ Almost at your limit!' : 'Resets in 24 hours',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isNearLimit
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6B7280),
                ),
              ),
              Text(
                '$messagesUsed / $messagesLimit messages',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
