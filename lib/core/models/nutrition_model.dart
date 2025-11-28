class NutritionModel {
  final String? id;
  final String userId;
  final DateTime date;
  final double? caloriesTarget;
  final double? proteinTargetG;
  final double? carbsTargetG;
  final double? fatsTargetG;
  final double? caloriesConsumed;
  final double? proteinConsumedG;
  final double? carbsConsumedG;
  final double? fatsConsumedG;
  final int? waterMl;
  final double? fiberG;
  final double? sodiumMg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NutritionModel({
    this.id,
    required this.userId,
    required this.date,
    this.caloriesTarget,
    this.proteinTargetG,
    this.carbsTargetG,
    this.fatsTargetG,
    this.caloriesConsumed,
    this.proteinConsumedG,
    this.carbsConsumedG,
    this.fatsConsumedG,
    this.waterMl,
    this.fiberG,
    this.sodiumMg,
    this.createdAt,
    this.updatedAt,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      caloriesTarget: json['calories_target']?.toDouble(),
      proteinTargetG: json['protein_target_g']?.toDouble(),
      carbsTargetG: json['carbs_target_g']?.toDouble(),
      fatsTargetG: json['fats_target_g']?.toDouble(),
      caloriesConsumed: json['calories_consumed']?.toDouble(),
      proteinConsumedG: json['protein_consumed_g']?.toDouble(),
      carbsConsumedG: json['carbs_consumed_g']?.toDouble(),
      fatsConsumedG: json['fats_consumed_g']?.toDouble(),
      waterMl: json['water_ml'],
      fiberG: json['fiber_g']?.toDouble(),
      sodiumMg: json['sodium_mg']?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'calories_target': caloriesTarget,
      'protein_target_g': proteinTargetG,
      'carbs_target_g': carbsTargetG,
      'fats_target_g': fatsTargetG,
      'calories_consumed': caloriesConsumed,
      'protein_consumed_g': proteinConsumedG,
      'carbs_consumed_g': carbsConsumedG,
      'fats_consumed_g': fatsConsumedG,
      'water_ml': waterMl,
      'fiber_g': fiberG,
      'sodium_mg': sodiumMg,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}