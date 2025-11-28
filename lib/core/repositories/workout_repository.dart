import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_model.dart';
import '../models/workout_schedule_model.dart';
import '../config/supabase_config.dart';

class WorkoutRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      final response = await _client
          .from('workouts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => WorkoutModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts: $e');
    }
  }

  Future<WorkoutModel?> getWorkoutById(String workoutId) async {
    try {
      final response = await _client
          .from('workouts')
          .select()
          .eq('id', workoutId)
          .single();

      return WorkoutModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch workout: $e');
    }
  }

  Future<WorkoutModel> createWorkout(WorkoutModel workout) async {
    try {
      final response = await _client
          .from('workouts')
          .insert(workout.toJson())
          .select()
          .single();

      return WorkoutModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }

  Future<WorkoutModel> updateWorkout(WorkoutModel workout) async {
    try {
      final response = await _client
          .from('workouts')
          .update(workout.toJson())
          .eq('id', workout.id!)
          .select()
          .single();

      return WorkoutModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _client
          .from('workouts')
          .delete()
          .eq('id', workoutId);
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  // Workout Schedules
  Future<List<WorkoutScheduleModel>> getWorkoutSchedules(String userId, {DateTime? date}) async {
    try {
      var query = _client
          .from('workout_schedules')
          .select('*, workouts(*)')
          .eq('user_id', userId);

      if (date != null) {
        query = query.eq('scheduled_date', date.toIso8601String().split('T')[0]);
      }

      final response = await query.order('scheduled_date', ascending: true);

      return response.map((json) => WorkoutScheduleModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workout schedules: $e');
    }
  }

  Future<WorkoutScheduleModel> createWorkoutSchedule(WorkoutScheduleModel schedule) async {
    try {
      final response = await _client
          .from('workout_schedules')
          .insert(schedule.toJson())
          .select()
          .single();

      return WorkoutScheduleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create workout schedule: $e');
    }
  }

  Future<WorkoutScheduleModel> updateWorkoutSchedule(WorkoutScheduleModel schedule) async {
    try {
      final response = await _client
          .from('workout_schedules')
          .update(schedule.toJson())
          .eq('id', schedule.id!)
          .select()
          .single();

      return WorkoutScheduleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update workout schedule: $e');
    }
  }

  Future<List<WorkoutScheduleModel>> getUserWorkoutSchedules(String userId) async {
    try {
      // Get all schedules for the user (including past ones for now)
      final response = await _client
          .from('workout_schedules')
          .select()
          .eq('user_id', userId)
          .order('scheduled_date', ascending: true)
          .order('scheduled_time', ascending: true);

      print('Raw response from Supabase: $response');

      final schedules = response.map((json) => WorkoutScheduleModel.fromJson(json)).toList();
      
      // Filter locally to show only upcoming schedules
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];
      
      final upcomingSchedules = schedules.where((schedule) {
        final scheduleDateStr = schedule.scheduledDate.toIso8601String().split('T')[0];
        return scheduleDateStr.compareTo(todayStr) >= 0;
      }).toList();

      print('Filtered to ${upcomingSchedules.length} upcoming schedules');

      return upcomingSchedules;
    } catch (e) {
      print('Repository error: $e');
      throw Exception('Failed to fetch workout schedules: $e');
    }
  }

  Future<void> deleteWorkoutSchedule(String scheduleId) async {
    try {
      await _client
          .from('workout_schedules')
          .delete()
          .eq('id', scheduleId);
    } catch (e) {
      throw Exception('Failed to delete workout schedule: $e');
    }
  }
}