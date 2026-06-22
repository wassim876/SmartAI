class StatsModel {
  final int totalChats;
  final int imagesAnalyzed;
  final int hoursSaved;

  StatsModel({
    this.totalChats = 0,
    this.imagesAnalyzed = 0,
    this.hoursSaved = 0,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      totalChats: json['total_chats'] ?? 0,
      imagesAnalyzed: json['images_analyzed'] ?? 0,
      hoursSaved: json['hours_saved'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_chats': totalChats,
      'images_analyzed': imagesAnalyzed,
      'hours_saved': hoursSaved,
    };
  }
}