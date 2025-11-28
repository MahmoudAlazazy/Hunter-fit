import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_group_model.dart';
import '../models/exercise_model.dart';

class WorkoutGroupService {
  static const String _workoutGroupsKey = 'workout_groups';
  static const String _completedWorkoutsKey = 'completed_workouts';
  
  static final WorkoutGroupService _instance = WorkoutGroupService._internal();
  factory WorkoutGroupService() => _instance;
  WorkoutGroupService._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<List<WorkoutGroupModel>> getWorkoutGroups() async {
    try {
      final prefs = await _prefs;
      final String? workoutGroupsJson = prefs.getString(_workoutGroupsKey);
      
      if (workoutGroupsJson == null) {
        return [];
      }

      final List<dynamic> workoutGroupsList = json.decode(workoutGroupsJson);
      return workoutGroupsList
          .map((json) => WorkoutGroupModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading workout groups: $e');
      return [];
    }
  }

  Future<void> saveWorkoutGroup(WorkoutGroupModel workoutGroup) async {
    try {
      final prefs = await _prefs;
      final workoutGroups = await getWorkoutGroups();
      
      final existingIndex = workoutGroups.indexWhere((g) => g.id == workoutGroup.id);
      if (existingIndex >= 0) {
        workoutGroups[existingIndex] = workoutGroup;
      } else {
        workoutGroups.add(workoutGroup);
      }

      final workoutGroupsJson = json.encode(
        workoutGroups.map((g) => g.toJson()).toList(),
      );
      
      await prefs.setString(_workoutGroupsKey, workoutGroupsJson);
    } catch (e) {
      print('Error saving workout group: $e');
      rethrow;
    }
  }

  Future<void> updateWorkoutGroup(WorkoutGroupModel workoutGroup) async {
    return saveWorkoutGroup(workoutGroup);
  }

  Future<void> deleteWorkoutGroup(String groupId) async {
    try {
      final prefs = await _prefs;
      final workoutGroups = await getWorkoutGroups();
      
      workoutGroups.removeWhere((g) => g.id == groupId);

      final workoutGroupsJson = json.encode(
        workoutGroups.map((g) => g.toJson()).toList(),
      );
      
      await prefs.setString(_workoutGroupsKey, workoutGroupsJson);
    } catch (e) {
      print('Error deleting workout group: $e');
      rethrow;
    }
  }

  Future<WorkoutGroupModel?> getWorkoutGroup(String groupId) async {
    try {
      final workoutGroups = await getWorkoutGroups();
      for (var group in workoutGroups) {
        if (group.id == groupId) {
          return group;
        }
      }
      return null;
    } catch (e) {
      print('Error getting workout group: $e');
      return null;
    }
  }

  Future<void> updateExerciseCompletion(
    String groupId,
    String exerciseId,
    bool isCompleted,
  ) async {
    try {
      final workoutGroup = await getWorkoutGroup(groupId);
      if (workoutGroup == null) {
        throw Exception('Workout group not found');
      }

      final updatedExercises = workoutGroup.exercises.map((exercise) {
        if (exercise.exercise.id == exerciseId) {
          return exercise.copyWith(
            isCompleted: isCompleted,
            completedDate: isCompleted ? DateTime.now() : null,
          );
        }
        return exercise;
      }).toList();

      final updatedGroup = workoutGroup.copyWith(
        exercises: updatedExercises,
        lastModifiedDate: DateTime.now(),
      );

      await saveWorkoutGroup(updatedGroup);
    } catch (e) {
      print('Error updating exercise completion: $e');
      rethrow;
    }
  }

  Future<void> addExerciseToGroup(
    String groupId,
    ExerciseModel exercise,
    int sets,
    int reps,
  ) async {
    try {
      final workoutGroup = await getWorkoutGroup(groupId);
      if (workoutGroup == null) {
        throw Exception('Workout group not found');
      }

      final newExercise = WorkoutGroupExercise(
        exercise: exercise,
        sets: sets,
        reps: reps,
      );

      final updatedExercises = [...workoutGroup.exercises, newExercise];
      final updatedGroup = workoutGroup.copyWith(
        exercises: updatedExercises,
        lastModifiedDate: DateTime.now(),
      );

      await saveWorkoutGroup(updatedGroup);
    } catch (e) {
      print('Error adding exercise to group: $e');
      rethrow;
    }
  }

  Future<void> removeExerciseFromGroup(String groupId, String exerciseId) async {
    try {
      final workoutGroup = await getWorkoutGroup(groupId);
      if (workoutGroup == null) {
        throw Exception('Workout group not found');
      }

      final updatedExercises = workoutGroup.exercises
          .where((e) => e.exercise.id != exerciseId)
          .toList();

      final updatedGroup = workoutGroup.copyWith(
        exercises: updatedExercises,
        lastModifiedDate: DateTime.now(),
      );

      await saveWorkoutGroup(updatedGroup);
    } catch (e) {
      print('Error removing exercise from group: $e');
      rethrow;
    }
  }

  String generateGroupId() {
    return const Uuid().v4();
  }

  Future<void> logCompletedWorkout(String groupId, String exerciseId) async {
    try {
      final prefs = await _prefs;
      final String key = '${_completedWorkoutsKey}_$groupId';
      final String? completedJson = prefs.getString(key);
      
      List<Map<String, dynamic>> completedList = [];
      if (completedJson != null) {
        completedList = List<Map<String, dynamic>>.from(json.decode(completedJson));
      }

      completedList.add({
        'exercise_id': exerciseId,
        'completed_date': DateTime.now().toIso8601String(),
      });

      await prefs.setString(key, json.encode(completedList));
    } catch (e) {
      print('Error logging completed workout: $e');
      rethrow;
    }
  }

  Future<List<DateTime>> getCompletedWorkoutsForGroup(String groupId) async {
    try {
      final prefs = await _prefs;
      final String key = '${_completedWorkoutsKey}_$groupId';
      final String? completedJson = prefs.getString(key);
      
      if (completedJson == null) {
        return [];
      }

      final List<dynamic> completedList = json.decode(completedJson);
      return completedList
          .map((item) => DateTime.parse(item['completed_date']))
          .toList();
    } catch (e) {
      print('Error getting completed workouts: $e');
      return [];
    }
  }
}