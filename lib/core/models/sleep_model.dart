class SleepModel {
  final String? id;
  final String userId;
  final DateTime date;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int durationMinutes;
  final int? qualityScore;
  final String? notes;
  final DateTime? createdAt;

  SleepModel({
    this.id,
    required this.userId,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.durationMinutes,
    this.qualityScore,
    this.notes,
    this.createdAt,
  });

  factory SleepModel.fromJson(Map<String, dynamic> json) {
    return SleepModel(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      bedtime: DateTime.parse(json['bedtime']),
      wakeTime: DateTime.parse(json['wake_time']),
      durationMinutes: json['duration_minutes'],
      qualityScore: json['quality_score'],
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'bedtime': bedtime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'quality_score': qualityScore,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get durationFormatted {
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get bedtimeFormatted {
    return '${bedtime.hour.toString().padLeft(2, '0')}:${bedtime.minute.toString().padLeft(2, '0')}';
  }

  String get wakeTimeFormatted {
    return '${wakeTime.hour.toString().padLeft(2, '0')}:${wakeTime.minute.toString().padLeft(2, '0')}';
  }
}