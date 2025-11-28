class WorkoutScheduleModel {
  final String? id;
  final String userId;
  final String workoutId;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutScheduleModel({
    this.id,
    required this.userId,
    required this.workoutId,
    required this.scheduledDate,
    this.scheduledTime,
    this.status = 'scheduled',
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorkoutScheduleModel(
      id: json['id'],
      userId: json['user_id'],
      workoutId: json['workout_id'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      scheduledTime: json['scheduled_time'],
      status: json['status'] ?? 'scheduled',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'workout_id': workoutId,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_time': scheduledTime,
      'status': status,
    };
    
    // Only include id if it exists (for updates, not for creation)
    if (id != null) {
      data['id'] = id;
    }
    
    // Only include timestamps if they exist
    if (createdAt != null) {
      data['created_at'] = createdAt?.toIso8601String();
    }
    if (updatedAt != null) {
      data['updated_at'] = updatedAt?.toIso8601String();
    }
    
    return data;
  }
}