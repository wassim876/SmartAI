class UserModel {
  final int id;
  final String username;
  final String email;
  final String name;
  final bool isAdmin;
  final bool isPremium;
  final int dailyMessagesUsed;
  final int dailyMessagesLimit;
  final int monthlySpeechMinutesUsed;
  final int monthlySpeechMinutesLimit;
  final int translationCharsUsed;
  final int translationCharsLimit;
  final DateTime lastResetDate;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.isAdmin,
    required this.isPremium,
    required this.dailyMessagesUsed,
    required this.dailyMessagesLimit,
    required this.monthlySpeechMinutesUsed,
    required this.monthlySpeechMinutesLimit,
    required this.translationCharsUsed,
    required this.translationCharsLimit,
    required this.lastResetDate,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'] ?? json['username'],
      // Maps Django is_staff/is_superuser to isAdmin
      isAdmin: json['is_staff'] == true || json['is_superuser'] == true,
      isPremium: json['is_premium'] ?? false,
      dailyMessagesUsed: json['daily_messages_used'] ?? 0,
      dailyMessagesLimit: json['daily_messages_limit'] ?? 50,
      monthlySpeechMinutesUsed: json['monthly_speech_minutes_used'] ?? 0,
      monthlySpeechMinutesLimit: json['monthly_speech_minutes_limit'] ?? 10,
      translationCharsUsed: json['translation_chars_used'] ?? 0,
      translationCharsLimit: json['translation_chars_limit'] ?? 1000,
      lastResetDate: json['last_reset_date'] != null
          ? DateTime.parse(json['last_reset_date'])
          : DateTime.now(),
      avatarUrl: json['profile_picture'],
    );
  }

  UserModel copyWith({
    int? dailyMessagesUsed,
    int? translationCharsUsed,
    DateTime? lastResetDate,
  }) {
    return UserModel(
      id: id,
      username: username,
      email: email,
      name: name,
      isAdmin: isAdmin,
      isPremium: isPremium,
      dailyMessagesUsed: dailyMessagesUsed ?? this.dailyMessagesUsed,
      dailyMessagesLimit: dailyMessagesLimit,
      monthlySpeechMinutesUsed: monthlySpeechMinutesUsed,
      monthlySpeechMinutesLimit: monthlySpeechMinutesLimit,
      translationCharsUsed: translationCharsUsed ?? this.translationCharsUsed,
      translationCharsLimit: translationCharsLimit,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      avatarUrl: avatarUrl,
    );
  }
}
