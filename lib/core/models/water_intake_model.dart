class WaterIntakeModel {
  final String id;
  final String userId;
  final DateTime date;
  final String timeSlot;
  final int amountMl;
  final DateTime? createdAt;

  WaterIntakeModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.timeSlot,
    required this.amountMl,
    this.createdAt,
  });

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'] ?? '', // Provide default empty string if ID is missing
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      timeSlot: json['time_slot'],
      amountMl: json['amount_ml'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'time_slot': timeSlot,
      'amount_ml': amountMl,
      'created_at': createdAt?.toIso8601String(),
    };
    
    // Only include ID if it's not null or empty (for existing records)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }
}