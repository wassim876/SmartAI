import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final progress = messagesUsed / messagesLimit;
    final isNearLimit = progress > 0.8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNearLimit ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNearLimit ? Colors.orange.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily AI Messages',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isNearLimit
                      ? Colors.orange.shade800
                      : Colors.blue.shade800,
                ),
              ),
              Text(
                '$messagesUsed / $messagesLimit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isNearLimit
                      ? Colors.orange.shade800
                      : Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearLimit ? Colors.orange : Colors.blue,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNearLimit ? 'Almost at limit!' : 'Resets in 24 hours',
                style: TextStyle(
                  fontSize: 12,
                  color: isNearLimit
                      ? Colors.orange.shade700
                      : Colors.blue.shade700,
                ),
              ),
              TextButton(
                onPressed: onUpgradeTap,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  'Upgrade',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isNearLimit
                        ? Colors.orange.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
