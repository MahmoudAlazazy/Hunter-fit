import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/nutrition_model.dart';
import '../models/water_intake_model.dart';
import '../config/supabase_config.dart';

class NutritionRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<NutritionModel?> getNutritionForDate(String userId, DateTime date) async {
    try {
      final response = await _client
          .from('nutrition')
          .select()
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0])
          .single();

      return NutritionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<NutritionModel>> getNutritionHistory(String userId, {int limit = 30}) async {
    try {
      final response = await _client
          .from('nutrition')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(limit);

      return response.map((json) => NutritionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch nutrition history: $e');
    }
  }

  Future<NutritionModel> createOrUpdateNutrition(NutritionModel nutrition) async {
    try {
      final existing = await getNutritionForDate(nutrition.userId, nutrition.date);
      
      if (existing != null) {
        final response = await _client
            .from('nutrition')
            .update(nutrition.toJson())
            .eq('id', existing.id!)
            .select()
            .single();
        return NutritionModel.fromJson(response);
      } else {
        final response = await _client
            .from('nutrition')
            .insert(nutrition.toJson())
            .select()
            .single();
        return NutritionModel.fromJson(response);
      }
    } catch (e) {
      throw Exception('Failed to save nutrition: $e');
    }
  }

  // Water Intake
  Future<List<WaterIntakeModel>> getWaterIntakeForDate(String userId, DateTime date) async {
    try {
      final response = await _client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0])
          .order('time_slot', ascending: true);

      return response.map((json) => WaterIntakeModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch water intake: $e');
    }
  }

  // Meals
  Future<List<Map<String, dynamic>>> getMealsForDate(String userId, DateTime date) async {
    try {
      final response = await _client
          .from('meals')
          .select()
          .eq('user_id', userId)
          .gte('served_at', DateTime(date.year, date.month, date.day).toIso8601String())
          .lt('served_at', DateTime(date.year, date.month, date.day + 1).toIso8601String())
          .order('served_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch meals: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchFoods({String? query, int limit = 50}) async {
    try {
      var req = _client.from('foods').select();
      if (query != null && query.trim().isNotEmpty) {
        req = req.ilike('name', '%${query.trim()}%');
      }
      final response = await req.limit(limit).order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search foods: $e');
    }
  }

  Future<Map<String, dynamic>> addMealItem({
    required String mealId,
    required String foodId,
    required double servings,
  }) async {
    try {
      final response = await _client
          .from('meal_items')
          .insert({
            'meal_id': mealId,
            'food_id': foodId,
            'servings': servings,
          })
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to add meal item: $e');
    }
  }

  Future<bool> deleteMealItem(String mealItemId) async {
    try {
      await _client
          .from('meal_items')
          .delete()
          .eq('id', mealItemId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete meal item: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMealItemsForRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client
          .from('meal_items')
          .select('*, meals!inner(user_id, served_at, meal_type), foods!inner(name, brand, serving_size_g, image_url)')
          .eq('meals.user_id', userId)
          .gte('meals.served_at', startDate.toIso8601String())
          .lt('meals.served_at', endDate.toIso8601String());
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch meal items for range: $e');
    }
  }

  Future<Map<String, dynamic>> addMealWithCalories({
    required String userId,
    required String mealType,
    required String name,
    required DateTime servedAt,
    required double caloriesKcal,
  }) async {
    try {
      final mealPayload = {
        'user_id': userId,
        'meal_type': mealType,
        'name': name,
        'served_at': servedAt.toIso8601String(),
      };
      final meal = await _client
          .from('meals')
          .insert(mealPayload)
          .select()
          .single();

      await _client
          .from('calorie_logs')
          .insert({
            'user_id': userId,
            'source': 'meal',
            'amount_kcal': caloriesKcal,
            'ref_table': 'meals',
            'ref_id': meal['id'],
            'occurred_at': servedAt.toIso8601String(),
          });

      final dateOnly = DateTime(servedAt.year, servedAt.month, servedAt.day);
      final existing = await getNutritionForDate(userId, dateOnly);
      final updated = NutritionModel(
        id: existing?.id,
        userId: userId,
        date: dateOnly,
        caloriesTarget: existing?.caloriesTarget,
        proteinTargetG: existing?.proteinTargetG,
        carbsTargetG: existing?.carbsTargetG,
        fatsTargetG: existing?.fatsTargetG,
        caloriesConsumed: (existing?.caloriesConsumed ?? 0) + caloriesKcal,
        proteinConsumedG: existing?.proteinConsumedG,
        carbsConsumedG: existing?.carbsConsumedG,
        fatsConsumedG: existing?.fatsConsumedG,
        waterMl: existing?.waterMl,
        fiberG: existing?.fiberG,
        sodiumMg: existing?.sodiumMg,
      );
      await createOrUpdateNutrition(updated);

      return meal;
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  Future<WaterIntakeModel> addWaterIntake(WaterIntakeModel waterIntake) async {
    try {
      final response = await _client
          .from('water_intake')
          .insert(waterIntake.toJson())
          .select()
          .limit(1);

      if (response.isEmpty) {
        throw Exception('No response from server');
      }
      
      return WaterIntakeModel.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to add water intake: $e');
    }
  }

  Future<void> deleteWaterIntake(String intakeId) async {
    try {
      await _client
          .from('water_intake')
          .delete()
          .eq('id', intakeId);
    } catch (e) {
      throw Exception('Failed to delete water intake: $e');
    }
  }

  // Get total water intake for date
  Future<int> getTotalWaterIntakeForDate(String userId, DateTime date) async {
    try {
      final response = await _client
          .from('water_intake')
          .select('amount_ml')
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0]);

      return response.fold<int>(0, (sum, item) => sum + (item['amount_ml'] as int));
    } catch (e) {
      return 0;
    }
  }
}
