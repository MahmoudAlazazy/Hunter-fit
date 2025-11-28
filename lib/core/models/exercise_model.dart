
enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

class ExerciseModel {
  final String id;
  final String name;
  final String displayName;
  final String muscleGroup;
  final String? description;
  final ExerciseDifficulty difficulty;
  final String? equipment;
  final String? targetMuscles;
  final String? instructions;
  final String? tips;
  final String? imagePath;
  final String? gifPath;
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final int? restSeconds;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.muscleGroup,
    this.description,
    this.difficulty = ExerciseDifficulty.beginner,
    this.equipment,
    this.targetMuscles,
    this.instructions,
    this.tips,
    this.imagePath,
    this.gifPath,
    this.sets,
    this.reps,
    this.durationSeconds,
    this.restSeconds,
  });

  factory ExerciseModel.fromAssetPath(String assetPath, String muscleGroup) {
    final fileName = assetPath.split('/').last;
    final name = fileName
        .replaceAll('-', ' ')
        .replaceAll('.gif', '')
        .replaceAll('.png', '')
        .replaceAll('.jpg', '')
        .replaceAll('.jpeg', '')
        .replaceAll('.webp', '')
        .trim();
    
    final displayName = _formatDisplayName(name);
    final difficulty = _determineDifficulty(name, muscleGroup);
    final description = _generateDescription(name, muscleGroup);
    final targetMuscles = _getTargetMuscles(name, muscleGroup);
    final equipment = _getEquipment(name);
    final instructions = _getInstructions(name, muscleGroup);
    final tips = _getTips(name, muscleGroup);

    print('Creating exercise from asset: $assetPath');
    print('File name: $fileName, Exercise name: $name');

    return ExerciseModel(
      id: '${muscleGroup}_${name.toLowerCase().replaceAll(' ', '_')}',
      name: name.toLowerCase().replaceAll(' ', '_'),
      displayName: displayName,
      muscleGroup: muscleGroup,
      description: description,
      difficulty: difficulty,
      equipment: equipment,
      targetMuscles: targetMuscles,
      instructions: instructions,
      tips: tips,
      gifPath: assetPath,
      sets: _getRecommendedSets(name, difficulty),
      reps: _getRecommendedReps(name, difficulty),
      durationSeconds: _getDurationSeconds(name, difficulty),
      restSeconds: _getRestSeconds(difficulty),
    );
  }

  static String _formatDisplayName(String name) {
    return name.split(' ').map((word) {
      if (word.length > 2) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word.toUpperCase();
    }).join(' ');
  }

  static ExerciseDifficulty _determineDifficulty(String name, String muscleGroup) {
    final advancedKeywords = [
      'advanced', 'expert', 'heavy', 'weighted', 'decline', 'incline',
      'hanging', 'standing', 'one arm', 'single arm', 'alternating',
      'dragon flag', 'flag', 'planche', 'front lever', 'back lever'
    ];
    
    final intermediateKeywords = [
      'cable', 'machine', 'barbell', 'dumbbell', 'kettlebell',
      'stability', 'ball', 'bosu', 'medicine', 'resistance'
    ];

    final nameLower = name.toLowerCase();
    
    if (advancedKeywords.any((keyword) => nameLower.contains(keyword))) {
      return ExerciseDifficulty.advanced;
    } else if (intermediateKeywords.any((keyword) => nameLower.contains(keyword))) {
      return ExerciseDifficulty.intermediate;
    } else {
      return ExerciseDifficulty.beginner;
    }
  }

  static String _generateDescription(String name, String muscleGroup) {
    final displayName = _formatDisplayName(name);
    final muscleGroupDescriptions = {
      'abs_core': 'core stability and abdominal strength',
      'chest': 'chest development and upper body strength',
      'back': 'back strength and posture improvement',
      'shoulders': 'shoulder stability and deltoid development',
      'biceps': 'bicep strength and arm definition',
      'triceps': 'tricep strength and arm toning',
      'legs': 'lower body strength and muscle development',
      'glutes': 'glute activation and lower body power',
      'calf': 'calf muscle strength and definition',
      'forearm': 'grip strength and forearm development',
      'neck': 'neck strength and stability',
      'cardio': 'cardiovascular endurance and fat burning',
      'full_body': 'full body coordination and functional fitness',
    };
    
    final targetDescription = muscleGroupDescriptions[muscleGroup] ?? '${muscleGroup.toLowerCase()} muscle development';
    return '$displayName is an effective exercise targeting $targetDescription. This exercise helps build strength, improve muscle definition, enhance functional fitness, and support overall athletic performance.';
  }

  static String _getTargetMuscles(String name, String muscleGroup) {
    final targetMuscleMap = {
      'abs_core': 'Rectus abdominis, Obliques, Transverse abdominis',
      'chest': 'Pectoralis major, Pectoralis minor, Triceps',
      'back': 'Latissimus dorsi, Rhomboids, Trapezius, Erector spinae',
      'shoulders': 'Deltoids, Trapezius, Rotator cuff muscles',
      'biceps': 'Biceps brachii, Brachialis, Brachioradialis',
      'triceps': 'Triceps brachii, Anconeus',
      'legs': 'Quadriceps, Hamstrings, Glutes, Calves',
      'glutes': 'Gluteus maximus, Gluteus medius, Gluteus minimus',
      'calf': 'Gastrocnemius, Soleus',
      'forearm': 'Flexor muscles, Extensor muscles',
      'neck': 'Sternocleidomastoid, Trapezius',
      'cardio': 'Heart, Lungs, Full body cardiovascular system',
      'full_body': 'Multiple muscle groups, Full body workout',
    };

    return targetMuscleMap[muscleGroup] ?? '$muscleGroup muscles';
  }

  static String? _getEquipment(String name) {
    final nameLower = name.toLowerCase();
    
    if (nameLower.contains('barbell')) return 'Barbell';
    if (nameLower.contains('dumbbell')) return 'Dumbbell';
    if (nameLower.contains('cable')) return 'Cable Machine';
    if (nameLower.contains('machine')) return 'Exercise Machine';
    if (nameLower.contains('medicine ball')) return 'Medicine Ball';
    if (nameLower.contains('stability ball')) return 'Stability Ball';
    if (nameLower.contains('resistance')) return 'Resistance Bands';
    if (nameLower.contains('kettlebell')) return 'Kettlebell';
    if (nameLower.contains('trx') || nameLower.contains('suspended')) return 'TRX/Suspension Trainer';
    if (nameLower.contains('bodyweight') || nameLower.contains('no equipment')) return 'None (Bodyweight)';
    
    return 'None (Bodyweight)';
  }

  static String _getInstructions(String name, String muscleGroup) {
    final displayName = _formatDisplayName(name);
    return 
        '1. Start by getting into the proper starting position\n'
        '2. Focus on proper form and controlled movement\n'
        '3. Execute the exercise movement smoothly\n'
        '4. Maintain tension in the target muscles throughout\n'
        '5. Return to starting position with control\n'
        '6. Repeat for desired repetitions';
  }

  static String _getTips(String name, String muscleGroup) {
    return 
        '• Focus on form over speed\n'
        '• Breathe properly throughout the movement\n'
        '• Start with lighter intensity if new to the exercise\n'
        '• Warm up properly before starting\n'
        '• Listen to your body and stop if you feel pain';
  }

  static int? _getRecommendedSets(String name, ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 2;
      case ExerciseDifficulty.intermediate:
        return 3;
      case ExerciseDifficulty.advanced:
        return 4;
    }
  }

  static int? _getRecommendedReps(String name, ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 10;
      case ExerciseDifficulty.intermediate:
        return 12;
      case ExerciseDifficulty.advanced:
        return 15;
    }
  }

  static int? _getDurationSeconds(String name, ExerciseDifficulty difficulty) {
    if (name.toLowerCase().contains('plank') || name.toLowerCase().contains('hold')) {
      switch (difficulty) {
        case ExerciseDifficulty.beginner:
          return 30;
        case ExerciseDifficulty.intermediate:
          return 45;
        case ExerciseDifficulty.advanced:
          return 60;
      }
    }
    return null;
  }

  static int? _getRestSeconds(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 60;
      case ExerciseDifficulty.intermediate:
        return 45;
      case ExerciseDifficulty.advanced:
        return 30;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'muscle_group': muscleGroup,
      'description': description,
      'difficulty': difficulty.name,
      'equipment': equipment,
      'target_muscles': targetMuscles,
      'instructions': instructions,
      'tips': tips,
      'image_path': imagePath,
      'gif_path': gifPath,
      'sets': sets,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
    };
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      muscleGroup: json['muscle_group'],
      description: json['description'],
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ExerciseDifficulty.beginner,
      ),
      equipment: json['equipment'],
      targetMuscles: json['target_muscles'],
      instructions: json['instructions'],
      tips: json['tips'],
      imagePath: json['image_path'],
      gifPath: json['gif_path'],
      sets: json['sets'],
      reps: json['reps'],
      durationSeconds: json['duration_seconds'],
      restSeconds: json['rest_seconds'],
    );
  }
}