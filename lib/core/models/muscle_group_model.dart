import 'dart:io';

class MuscleGroupModel {
  final String id;
  final String name;
  final String displayName;
  final String directoryName;
  final String? imagePath;
  final int exerciseCount;

  MuscleGroupModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.directoryName,
    this.imagePath,
    required this.exerciseCount,
  });

  factory MuscleGroupModel.fromDirectory(Directory directory) {
    final dirName = directory.path.split(Platform.pathSeparator).last;
    final displayName = _getDisplayName(dirName);
    final exerciseFiles = directory.listSync()
        .where((file) => file.path.toLowerCase().endsWith('.gif') || file.path.toLowerCase().endsWith('.png'))
        .length;

    return MuscleGroupModel(
      id: dirName.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'),
      name: _getMuscleGroupEnumValue(dirName),
      displayName: displayName,
      directoryName: dirName,
      imagePath: _getDefaultImagePath(dirName),
      exerciseCount: exerciseFiles,
    );
  }

  static String _getDisplayName(String directoryName) {
    final nameMap = {
      'Abs or core': 'Abs & Core',
      'Biceps': 'Biceps',
      'Triceps': 'Triceps',
      'Chest': 'Chest',
      'back or wing': 'Back & Wings',
      'Shoulders': 'Shoulders',
      'Leg': 'Legs',
      'Glutes': 'Glutes',
      'Calf': 'Calves',
      'Forearm': 'Forearms',
      'Trapezius': 'Traps',
      'Cardio': 'Cardio',
      'Erector spinae': 'Erector Spinae',
      'Full Body': 'Full Body',
      'Hips': 'Hips',
      'neck': 'Neck',
    };

    return nameMap[directoryName] ?? directoryName;
  }

  static String _getMuscleGroupEnumValue(String directoryName) {
    final enumMap = {
      'Abs or core': 'abs_core',
      'Biceps': 'biceps',
      'Triceps': 'triceps',
      'Chest': 'chest',
      'back or wing': 'back',
      'Shoulders': 'shoulders',
      'Leg': 'legs',
      'Glutes': 'glutes',
      'Calf': 'calf',
      'Forearm': 'forearm',
      'Trapezius': 'trapezius',
      'Cardio': 'cardio',
      'Erector spinae': 'erector_spinae',
      'Full Body': 'full_body',
      'Hips': 'hips',
      'neck': 'neck',
    };

    return enumMap[directoryName] ?? 'full_body';
  }

  static String? _getDefaultImagePath(String directoryName) {
    final imageMap = {
      'Abs or core': 'assets/img/what_3.png',
      'Biceps': 'assets/img/what_1.png',
      'Triceps': 'assets/img/what_1.png',
      'Chest': 'assets/img/what_1.png',
      'back or wing': 'assets/img/what_1.png',
      'Shoulders': 'assets/img/what_1.png',
      'Leg': 'assets/img/what_2.png',
      'Glutes': 'assets/img/what_2.png',
      'Calf': 'assets/img/what_2.png',
      'Forearm': 'assets/img/what_1.png',
      'Trapezius': 'assets/img/what_1.png',
      'Cardio': 'assets/img/what_1.png',
      'Erector spinae': 'assets/img/what_1.png',
      'Full Body': 'assets/img/what_1.png',
      'Hips': 'assets/img/what_2.png',
      'neck': 'assets/img/what_1.png',
    };

    return imageMap[directoryName] ?? 'assets/img/what_1.png';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'directory_name': directoryName,
      'image_path': imagePath,
      'exercise_count': exerciseCount,
    };
  }

  factory MuscleGroupModel.fromJson(Map<String, dynamic> json) {
    return MuscleGroupModel(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      directoryName: json['directory_name'],
      imagePath: json['image_path'],
      exerciseCount: json['exercise_count'],
    );
  }
}