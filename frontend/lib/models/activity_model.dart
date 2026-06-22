import 'package:flutter/material.dart';

class ActivityModel {
  final String id;
  final String type; // 'chat', 'speech', 'image'
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isLocked;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isLocked = false,
  });

  // Helper to get the right icon based on type
  IconData get icon {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'translate':
        return Icons.translate_outlined;
      case 'speech':
        return Icons.mic_outlined;
      case 'image':
        return Icons.image_outlined;
      default:
        return Icons.history;
    }
  }

  // Helper to get the right color based on type
  int get colorHex {
    switch (type) {
      case 'chat':
        return 0xFF9C27B0; // Purple
      case 'translate':
        return 0xFF4CAF50; // Green
      case 'speech':
        return 0xFF2196F3; // Blue
      case 'image':
        return 0xFFFF9800; // Orange
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  Color get color => Color(colorHex);

  // Format time (e.g., "2 minutes ago")
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'chat',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp']) ?? DateTime.now())
          : DateTime.now(),
      isLocked: json['is_locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
      'is_locked': isLocked,
    };
  }
}
