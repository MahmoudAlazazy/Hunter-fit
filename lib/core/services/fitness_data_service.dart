import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/workout_model.dart';
import '../models/workout_schedule_model.dart';
import '../models/nutrition_model.dart';
import '../models/water_intake_model.dart';
import '../models/sleep_model.dart';
import '../repositories/workout_repository.dart';
import '../repositories/nutrition_repository.dart';
import 'supabase_service.dart';

class FitnessDataService {
  static final WorkoutRepository _workoutRepo = WorkoutRepository();
  static final NutritionRepository _nutritionRepo = NutritionRepository();

  // Generate UUID for new records
  static String _generateUUID() {
    return const Uuid().v4(); // Generate proper UUID v4 format
  }

  // Workout Services
  static Future<List<WorkoutModel>> getLastWorkouts(String userId, {int limit = 3}) async {
    try {
      final workouts = await _workoutRepo.getUserWorkouts(userId);
      return workouts.take(limit).toList();
    } catch (e) {
      print('Error fetching last workouts: $e');
      return [];
    }
  }

  static Future<List<WorkoutScheduleModel>> getTodayWorkouts(String userId) async {
    try {
      final today = DateTime.now();
      return await _workoutRepo.getWorkoutSchedules(userId, date: today);
    } catch (e) {
      print('Error fetching today workouts: $e');
      return [];
    }
  }

  static Future<List<WorkoutScheduleModel>> getUpcomingWorkouts(String userId) async {
    try {
      final now = DateTime.now();
      final schedules = await _workoutRepo.getWorkoutSchedules(userId);
      
      return schedules.where((schedule) {
        final scheduleDate = schedule.scheduledDate;
        return scheduleDate.isAfter(now) || 
               (scheduleDate.year == now.year && 
                scheduleDate.month == now.month && 
                scheduleDate.day == now.day);
      }).toList();
    } catch (e) {
      print('Error fetching upcoming workouts: $e');
      return [];
    }
  }

  // Nutrition Services
  static Future<NutritionModel?> getTodayNutrition(String userId) async {
    try {
      final today = DateTime.now();
      return await _nutritionRepo.getNutritionForDate(userId, today);
    } catch (e) {
      print('Error fetching today nutrition: $e');
      return null;
    }
  }

  static Future<NutritionModel?> getNutritionForDate(String userId, DateTime date) async {
    try {
      return await _nutritionRepo.getNutritionForDate(userId, date);
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> addMealWithCalories({
    required String userId,
    required String mealType,
    required String name,
    required DateTime servedAt,
    required double caloriesKcal,
  }) async {
    try {
      return await _nutritionRepo.addMealWithCalories(
        userId: userId,
        mealType: mealType,
        name: name,
        servedAt: servedAt,
        caloriesKcal: caloriesKcal,
      );
    } catch (e) {
      print('Error adding meal with calories: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getMealsForDate(String userId, DateTime date) async {
    try {
      return await _nutritionRepo.getMealsForDate(userId, date);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> searchFoods({String? query, int limit = 50}) async {
    try {
      return await _nutritionRepo.searchFoods(query: query, limit: limit);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> addFoodToMeal({
    required String mealId,
    required String foodId,
    double servings = 1.0,
  }) async {
    try {
      return await _nutritionRepo.addMealItem(mealId: mealId, foodId: foodId, servings: servings);
    } catch (e) {
      print('Error adding food to meal: $e');
      return null;
    }
  }

  static Future<bool> deleteMealItem(String mealItemId) async {
    try {
      return await _nutritionRepo.deleteMealItem(mealItemId);
    } catch (e) {
      print('Error deleting meal item: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMealItemsForWeek(String userId, DateTime weekStart) async {
    try {
      final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final end = start.add(const Duration(days: 7));
      return await _nutritionRepo.getMealItemsForRange(userId: userId, startDate: start, endDate: end);
    } catch (e) {
      return [];
    }
  }

  // Weekly Meal Plan persistence (local)
  static String _weekKey(String userId, DateTime weekStart) {
    final d = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return 'week_plan_${userId}_$y$m$day';
  }

  static Future<void> saveWeekPlan(String userId, DateTime weekStart, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _weekKey(userId, weekStart);
    try {
      final serialized = items.map((e) => {
        'food_id': e['food_id']?.toString(),
        'meal_type': e['meal_type'],
        'day_offset': e['day_offset'],
        'servings': e['servings'] ?? 1.0,
      }).toList();
      await prefs.setString(key, jsonEncode(serialized));
    } catch (e) {
      // ignore
    }
  }

  static Future<List<Map<String, dynamic>>> loadWeekPlan(String userId, DateTime weekStart) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _weekKey(userId, weekStart);
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map<Map<String, dynamic>>((e) => {
        'food_id': e['food_id']?.toString(),
        'meal_type': e['meal_type'],
        'day_offset': (e['day_offset'] is String) ? int.tryParse(e['day_offset']) ?? 0 : (e['day_offset'] ?? 0),
        'servings': (e['servings'] is String) ? double.tryParse(e['servings']) ?? 1.0 : (e['servings'] ?? 1.0),
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> generateShoppingList(String userId, DateTime weekStart) async {
    try {
      final items = await getMealItemsForWeek(userId, weekStart);
      final Map<String, Map<String, dynamic>> agg = {};
      for (final it in items) {
        final food = it['foods'] ?? {};
        final name = food['name'] ?? '-';
        final brand = food['brand'];
        final sizeG = (food['serving_size_g'] ?? 0).toDouble();
        final image = food['image_url'];
        final servings = (it['servings'] ?? 1).toDouble();
        if (!agg.containsKey(name)) {
          agg[name] = {
            'name': name,
            'brand': brand,
            'image_url': image,
            'total_servings': 0.0,
            'total_grams': 0.0,
          };
        }
        agg[name]!['total_servings'] = (agg[name]!['total_servings'] as double) + servings;
        agg[name]!['total_grams'] = (agg[name]!['total_grams'] as double) + servings * sizeG;
      }
      return agg.values.toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<WaterIntakeModel>> getTodayWaterIntake(String userId) async {
    try {
      final today = DateTime.now();
      return await _nutritionRepo.getWaterIntakeForDate(userId, today);
    } catch (e) {
      print('Error fetching today water intake: $e');
      return [];
    }
  }

  static Future<int> getTotalWaterIntakeToday(String userId) async {
    try {
      final today = DateTime.now();
      return await _nutritionRepo.getTotalWaterIntakeForDate(userId, today);
    } catch (e) {
      print('Error fetching total water intake: $e');
      return 0;
    }
  }

  // Water Goal (local storage for now)
  static const String _kWaterGoalLitersKey = 'daily_water_goal_liters';

  static Future<double> getDailyWaterGoalLiters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_kWaterGoalLitersKey) ?? 4.0;
  }

  static Future<void> setDailyWaterGoalLiters(double liters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kWaterGoalLitersKey, liters);
  }

  static Future<WaterIntakeModel?> addWaterIntake({
    required String userId,
    required int amountMl,
    DateTime? at,
  }) async {
    try {
      final now = at ?? DateTime.now();
      String timeSlot;
      final hour = now.hour;
      if (hour >= 6 && hour < 9) {
        timeSlot = "6am - 8am";
      } else if (hour >= 9 && hour < 12) {
        timeSlot = "9am - 11am";
      } else if (hour >= 12 && hour < 15) {
        timeSlot = "11am - 2pm";
      } else if (hour >= 15 && hour < 17) {
        timeSlot = "2pm - 4pm";
      } else {
        timeSlot = "4pm - now";
      }

      final model = WaterIntakeModel(
        id: _generateUUID(), // Generate unique ID
        userId: userId,
        date: DateTime(now.year, now.month, now.day),
        timeSlot: timeSlot,
        amountMl: amountMl,
        createdAt: now,
      );
      return await _nutritionRepo.addWaterIntake(model);
    } catch (e) {
      print('Error adding water intake: $e');
      return null;
    }
  }

  // BMI Services
  static Future<Map<String, dynamic>?> getLatestBMI(String userId) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('bmi_history')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(1);
      
      if (response.isEmpty) return null;
      return response.first;
    } catch (e) {
      print('Error fetching latest BMI: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getBMIHistory(String userId, {int limit = 20}) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('bmi_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching BMI history: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createBMIRecord({
    required String userId,
    required double heightCm,
    required double weightKg,
    required double bmi,
    required String category,
  }) async {
    try {
      // First ensure profile exists
      final profile = await SupabaseService.getProfileById(userId);
      if (profile == null) {
        print('User profile does not exist, attempting to create it...');
        // Try to create a basic profile
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final success = await SupabaseService.createUserProfile(
            userId: userId,
            username: user.email?.split('@')[0] ?? 'user_$userId',
            fullName: user.userMetadata?['full_name'] ?? 'User',
            email: user.email,
          );
          
          if (!success) {
            print('Failed to create user profile for BMI record');
            return null;
          }
          print('User profile created successfully');
        } else {
          print('Cannot create BMI record: No authenticated user');
          return null;
        }
      }
      
      final client = Supabase.instance.client;
      final now = DateTime.now();
      final payload = {
        'user_id': userId,
        'date': now.toIso8601String().split('T')[0],
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'bmi': bmi,
        'category': category,
      };

      final inserted = await client
          .from('bmi_history')
          .insert(payload)
          .select()
          .limit(1);

      if (inserted.isEmpty) return null;
      return inserted.first;
    } catch (e) {
      print('Error creating BMI record: $e');
      return null;
    }
  }

  // Sleep Services
  static Future<Map<String, dynamic>?> getLatestSleep(String userId) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('sleep_tracking')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(1);
      
      if (response.isEmpty) return null;
      return response.first;
    } catch (e) {
      print('Error fetching latest sleep: $e');
      return null;
    }
  }

  static Future<List<SleepModel>> getSleepDataForDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('sleep_tracking')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);
      
      return response.map((json) => SleepModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching sleep data for date range: $e');
      return [];
    }
  }

  static Future<List<SleepModel>> getSleepDataForLastDays(String userId, int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days - 1));
      return await getSleepDataForDateRange(userId, startDate, endDate);
    } catch (e) {
      print('Error fetching sleep data for last days: $e');
      return [];
    }
  }

  static Future<SleepModel?> getSleepForDate(String userId, DateTime date) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('sleep_tracking')
          .select()
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0])
          .limit(1);
      
      if (response.isEmpty) return null;
      return SleepModel.fromJson(response.first);
    } catch (e) {
      print('Error fetching sleep for date: $e');
      return null;
    }
  }

  static Future<SleepModel?> createSleepRecord(SleepModel sleep) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('sleep_tracking')
          .insert(sleep.toJson())
          .select()
          .single();
      
      return SleepModel.fromJson(response);
    } catch (e) {
      print('Error creating sleep record: $e');
      return null;
    }
  }

  static Future<SleepModel?> updateSleepRecord(SleepModel sleep) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('sleep_tracking')
          .update(sleep.toJson())
          .eq('id', sleep.id!)
          .select()
          .single();
      
      return SleepModel.fromJson(response);
    } catch (e) {
      print('Error updating sleep record: $e');
      return null;
    }
  }

  static Future<void> deleteSleepRecord(String sleepId) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('sleep_tracking')
          .delete()
          .eq('id', sleepId);
    } catch (e) {
      print('Error deleting sleep record: $e');
    }
  }

  static Map<String, dynamic> convertSleepToChartData(List<SleepModel> sleepData) {
    if (sleepData.isEmpty) {
      return {
        'spots': const [
          FlSpot(1, 3),
          FlSpot(2, 5),
          FlSpot(3, 4),
          FlSpot(4, 7),
          FlSpot(5, 4),
          FlSpot(6, 8),
          FlSpot(7, 5),
        ],
        'maxValue': 10.0,
        'minValue': 0.0,
      };
    }

    List<FlSpot> spots = [];
    double maxValue = 0;
    double minValue = double.infinity;

    for (int i = 0; i < sleepData.length; i++) {
      final sleep = sleepData[i];
      final hours = sleep.durationMinutes / 60.0;
      spots.add(FlSpot(i + 1, hours));
      
      if (hours > maxValue) maxValue = hours;
      if (hours < minValue) minValue = hours;
    }

    // Fill missing days with 0 if we have less than 7 days
    while (spots.length < 7) {
      spots.add(FlSpot(spots.length + 1, 0));
    }

    // Add some padding to the chart range
    maxValue = maxValue + 1;
    minValue = minValue > 0 ? minValue - 1 : 0;

    return {
      'spots': spots,
      'maxValue': maxValue,
      'minValue': minValue,
    };
  }

  // Heart Rate Services
  static Future<Map<String, dynamic>?> getLatestHeartRate(String userId) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('heart_rate')
          .select()
          .eq('user_id', userId)
          .order('measured_at', ascending: false)
          .limit(1);
      
      if (response.isEmpty) return null;
      return response.first;
    } catch (e) {
      print('Error fetching latest heart rate: $e');
      return null;
    }
  }

  // Activity Services
  static Future<Map<String, dynamic>?> getTodayActivity(String userId) async {
    try {
      final client = Supabase.instance.client;
      final today = DateTime.now();
      final response = await client
          .from('activity_tracking')
          .select()
          .eq('user_id', userId)
          .eq('date', today.toIso8601String().split('T')[0])
          .limit(1);
      
      if (response.isEmpty) return null;
      return response.first;
    } catch (e) {
      print('Error fetching today activity: $e');
      return null;
    }
  }

  // Progress Photos Services
  static Future<List<Map<String, dynamic>>> getProgressPhotos(String userId) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('progress_photos')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      
      return response;
    } catch (e) {
      print('Error fetching progress photos: $e');
      return [];
    }
  }

  // Convert UI data format to database format
  static Map<String, dynamic> convertWorkoutToJson(Map<String, dynamic> workout) {
    return {
      'name': workout['name'],
      'image_url': workout['image'],
      'calories_burned': int.tryParse(workout['kcal'] ?? '0') ?? 0,
      'duration_minutes': int.tryParse(workout['time'] ?? '0') ?? 0,
      'progress_percentage': ((workout['progress'] ?? 0) * 100).round(),
    };
  }

  static Map<String, dynamic> convertWaterIntakeToJson(Map<String, dynamic> waterIntake) {
    return {
      'time_slot': waterIntake['title'],
      'amount_ml': int.tryParse(waterIntake['subtitle']?.replaceAll('ml', '') ?? '0') ?? 0,
    };
  }
}
