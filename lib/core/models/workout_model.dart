class WorkoutModel {
  final String? id;
  final String userId;
  final String title;
  final String? description;
  final String? difficulty;
  final int? durationMinutes;
  final bool isPrivate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutModel({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    this.difficulty,
    this.durationMinutes,
    this.isPrivate = false,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      difficulty: json['difficulty'],
      durationMinutes: json['duration_minutes'],
      isPrivate: json['is_private'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'duration_minutes': durationMinutes,
      'is_private': isPrivate,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}