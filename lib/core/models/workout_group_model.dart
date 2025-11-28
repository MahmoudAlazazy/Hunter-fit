import 'exercise_model.dart';

class WorkoutGroupExercise {
  final ExerciseModel exercise;
  int sets;
  int reps;
  int? durationSeconds;
  int? restSeconds;
  bool isCompleted;
  DateTime? completedDate;

  WorkoutGroupExercise({
    required this.exercise,
    this.sets = 3,
    this.reps = 12,
    this.durationSeconds,
    this.restSeconds = 60,
    this.isCompleted = false,
    this.completedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
      'is_completed': isCompleted,
      'completed_date': completedDate?.toIso8601String(),
    };
  }

  factory WorkoutGroupExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutGroupExercise(
      exercise: ExerciseModel.fromJson(json['exercise']),
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 12,
      durationSeconds: json['duration_seconds'],
      restSeconds: json['rest_seconds'] ?? 60,
      isCompleted: json['is_completed'] ?? false,
      completedDate: json['completed_date'] != null 
          ? DateTime.parse(json['completed_date']) 
          : null,
    );
  }

  WorkoutGroupExercise copyWith({
    ExerciseModel? exercise,
    int? sets,
    int? reps,
    int? durationSeconds,
    int? restSeconds,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return WorkoutGroupExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

class WorkoutGroupModel {
  final String id;
  final String name;
  final String? description;
  final String? imagePath;
  final List<WorkoutGroupExercise> exercises;
  final DateTime createdDate;
  final DateTime? lastModifiedDate;

  WorkoutGroupModel({
    required this.id,
    required this.name,
    this.description,
    this.imagePath,
    required this.exercises,
    required this.createdDate,
    this.lastModifiedDate,
  });

  int get totalExercises => exercises.length;
  
  int get completedExercises => exercises.where((e) => e.isCompleted).length;
  
  double get completionProgress => totalExercises > 0 
      ? completedExercises / totalExercises 
      : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'created_date': createdDate.toIso8601String(),
      'last_modified_date': lastModifiedDate?.toIso8601String(),
    };
  }

  factory WorkoutGroupModel.fromJson(Map<String, dynamic> json) {
    return WorkoutGroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['image_path'],
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutGroupExercise.fromJson(e))
          .toList(),
      createdDate: DateTime.parse(json['created_date']),
      lastModifiedDate: json['last_modified_date'] != null
          ? DateTime.parse(json['last_modified_date'])
          : null,
    );
  }

  WorkoutGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    List<WorkoutGroupExercise>? exercises,
    DateTime? createdDate,
    DateTime? lastModifiedDate,
  }) {
    return WorkoutGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      exercises: exercises ?? this.exercises,
      createdDate: createdDate ?? this.createdDate,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
    );
  }
}