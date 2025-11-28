import 'package:fitness/core/models/muscle_group_model.dart';
import 'package:fitness/core/models/exercise_model.dart';

class ExerciseImage {
  final String name;
  final String imagePath;
  final String muscleGroup;
  final String fileName;

  const ExerciseImage({
    required this.name,
    required this.imagePath,
    required this.muscleGroup,
    required this.fileName,
  });
}

class ExerciseImageManager {
  static const Map<String, String> muscleGroupFolders = {
    'Abs or Core': 'assets/exercise_images/Abs or core',
    'Back & Wings': 'assets/exercise_images/back or wing',
    'Biceps': 'assets/exercise_images/Biceps',
    'Calf': 'assets/exercise_images/Calf',
    'Cardio': 'assets/exercise_images/Cardio',
    'Chest': 'assets/exercise_images/chest',
    'Erector Spinae': 'assets/exercise_images/Erector spinae',
    'Forearm': 'assets/exercise_images/Forearm',
    'Full Body': 'assets/exercise_images/Full Body',
    'Hips': 'assets/exercise_images/Hips',
    'Leg': 'assets/exercise_images/Leg',
    'Neck': 'assets/exercise_images/neck',
    'Shoulder': 'assets/exercise_images/Shoulder',
    'Trapezius': 'assets/exercise_images/Trapezius',
    'Triceps': 'assets/exercise_images/Triceps',
  };

  // Method to get all muscle groups with their exercise counts
  static Future<List<MuscleGroupModel>> getMuscleGroups() async {
    final muscleGroups = <MuscleGroupModel>[];
    
    for (final entry in muscleGroupFolders.entries) {
      final muscleGroupName = entry.key;
      final folderPath = entry.value;
      final directoryName = _getDirectoryName(muscleGroupName);
      
      try {
        // Get exercises for this muscle group
        final exercises = await _getExercisesForFolder(folderPath, muscleGroupName);
        
        muscleGroups.add(MuscleGroupModel(
          id: muscleGroupName.toLowerCase().replaceAll(' ', '_'),
          name: _getMuscleGroupEnumValue(muscleGroupName),
          displayName: muscleGroupName,
          directoryName: directoryName,
          imagePath: _getDefaultImagePath(directoryName),
          exerciseCount: exercises.length,
        ));
      } catch (e) {
        print('Error loading exercises for $muscleGroupName: $e');
        // Add muscle group with 0 exercises if there's an error
        muscleGroups.add(MuscleGroupModel(
          id: muscleGroupName.toLowerCase().replaceAll(' ', '_'),
          name: _getMuscleGroupEnumValue(muscleGroupName),
          displayName: muscleGroupName,
          directoryName: directoryName,
          imagePath: _getDefaultImagePath(directoryName),
          exerciseCount: 0,
        ));
      }
    }
    
    return muscleGroups;
  }

  // Method to get exercises for a specific folder
  static Future<List<ExerciseImage>> _getExercisesForFolder(String folderPath, String muscleGroupName) async {
    final exercises = <ExerciseImage>[];
    
    // Since we can't dynamically scan assets in Flutter, we'll need to define exercises for each muscle group
    // For now, let's add the existing exercises and create placeholders for other muscle groups
    
    switch (muscleGroupName) {
      case 'Calf':
        exercises.addAll(_getCalfExercises());
        break;
      case 'Forearm':
        exercises.addAll(_getForearmExercises());
        break;
      case 'Hips':
        exercises.addAll(_getHipExercises());
        break;
      case 'Leg':
        exercises.addAll(_getLegExercises());
        break;
      case 'Shoulder':
        exercises.addAll(_getShoulderExercises());
        break;
      case 'Abs or Core':
        exercises.addAll(_getAbsCoreExercises());
        break;
      case 'Back & Wings':
        exercises.addAll(_getBackWingsExercises());
        break;
      case 'Biceps':
        exercises.addAll(_getBicepsExercises());
        break;
      case 'Cardio':
        exercises.addAll(_getCardioExercises());
        break;
      case 'Chest':
        exercises.addAll(_getChestExercises());
        break;
      case 'Erector Spinae':
        exercises.addAll(_getErectorSpinaeExercises());
        break;
      case 'Full Body':
        exercises.addAll(_getFullBodyExercises());
        break;
      case 'Neck':
        exercises.addAll(_getNeckExercises());
        break;
      case 'Trapezius':
        exercises.addAll(_getTrapeziusExercises());
        break;
      case 'Triceps':
        exercises.addAll(_getTricepsExercises());
        break;
    }
    
    return exercises;
  }

  // Calf exercises (23 exercises)
  static List<ExerciseImage> _getCalfExercises() {
    return [
      const ExerciseImage(name: 'Barbell Seated Calf Raise', imagePath: 'assets/exercise_images/Calf/Barbell-Seated-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Barbell-Seated-Calf-Raise.gif'),
      const ExerciseImage(name: 'Bench Press Machine Standing Calf Raise', imagePath: 'assets/exercise_images/Calf/Bench-Press-Machine-Standing-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Bench-Press-Machine-Standing-Calf-Raise.gif'),
      const ExerciseImage(name: 'Calf Stretch With Rope', imagePath: 'assets/exercise_images/Calf/Calf-Stretch-with-Rope.gif', muscleGroup: 'Calf', fileName: 'Calf-Stretch-with-Rope.gif'),
      const ExerciseImage(name: 'Donkey Calf Raise', imagePath: 'assets/exercise_images/Calf/Donkey-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Donkey-Calf-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Calf Raise', imagePath: 'assets/exercise_images/Calf/Dumbbell-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Dumbbell-Calf-Raise.gif'),
      const ExerciseImage(name: 'Hack Machine One Leg Calf Raise', imagePath: 'assets/exercise_images/Calf/Hack-Machine-One-Leg-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Hack-Machine-One-Leg-Calf-Raise.gif'),
      const ExerciseImage(name: 'Hack Squat Calf Raise', imagePath: 'assets/exercise_images/Calf/Hack-Squat-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Hack-Squat-Calf-Raise.gif'),
      const ExerciseImage(name: 'Leg Press Calf Raise', imagePath: 'assets/exercise_images/Calf/Leg-Press-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Leg-Press-Calf-Raise.gif'),
      const ExerciseImage(name: 'Lever Donkey Calf Raise', imagePath: 'assets/exercise_images/Calf/Lever-Donkey-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Lever-Donkey-Calf-Raise.gif'),
      const ExerciseImage(name: 'Lever Seated Calf Raise', imagePath: 'assets/exercise_images/Calf/Lever-Seated-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Lever-Seated-Calf-Raise.gif'),
      const ExerciseImage(name: 'Posterior Tibialis Stretch', imagePath: 'assets/exercise_images/Calf/Posterior-Tibialis-Stretch.gif', muscleGroup: 'Calf', fileName: 'Posterior-Tibialis-Stretch.gif'),
      const ExerciseImage(name: 'Resistance Band Foot External Rotation', imagePath: 'assets/exercise_images/Calf/Resistance-Band-Foot-External-Rotation.gif', muscleGroup: 'Calf', fileName: 'Resistance-Band-Foot-External-Rotation.gif'),
      const ExerciseImage(name: 'Seated Calf Press On Leg Press Machine', imagePath: 'assets/exercise_images/Calf/Seated-Calf-Press-on-Leg-Press-Machine.gif', muscleGroup: 'Calf', fileName: 'Seated-Calf-Press-on-Leg-Press-Machine.gif'),
      const ExerciseImage(name: 'Single Calf Raise On Leg Press Machine', imagePath: 'assets/exercise_images/Calf/Single-Calf-Raise-on-Leg-Press-Machine.gif', muscleGroup: 'Calf', fileName: 'Single-Calf-Raise-on-Leg-Press-Machine.gif'),
      const ExerciseImage(name: 'Single Leg Donkey Calf Raise', imagePath: 'assets/exercise_images/Calf/Single-Leg-Donkey-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Single-Leg-Donkey-Calf-Raise.gif'),
      const ExerciseImage(name: 'Squat Hold Calf Raise', imagePath: 'assets/exercise_images/Calf/Squat-Hold-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Squat-Hold-Calf-Raise.gif'),
      const ExerciseImage(name: 'Standing Barbell Calf Raise', imagePath: 'assets/exercise_images/Calf/Standing-Barbell-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Standing-Barbell-Calf-Raise.gif'),
      const ExerciseImage(name: 'Standing Calf Raise', imagePath: 'assets/exercise_images/Calf/Standing-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Standing-Calf-Raise.gif'),
      const ExerciseImage(name: 'Standing Dorsiflexion', imagePath: 'assets/exercise_images/Calf/Standing-Dorsiflexion.gif', muscleGroup: 'Calf', fileName: 'Standing-Dorsiflexion.gif'),
      const ExerciseImage(name: 'Standing Gastrocnemius Calf Stretch', imagePath: 'assets/exercise_images/Calf/Standing-Gastrocnemius-Calf-Stretch.gif', muscleGroup: 'Calf', fileName: 'Standing-Gastrocnemius-Calf-Stretch.gif'),
      const ExerciseImage(name: 'Standing Toe Up Achilles Stretch', imagePath: 'assets/exercise_images/Calf/Standing-Toe-Up-Achilles-Stretch.gif', muscleGroup: 'Calf', fileName: 'Standing-Toe-Up-Achilles-Stretch.gif'),
      const ExerciseImage(name: 'Standing Wall Calf Stretch', imagePath: 'assets/exercise_images/Calf/Standing-Wall-Calf-Stretch.gif', muscleGroup: 'Calf', fileName: 'Standing-Wall-Calf-Stretch.gif'),
      const ExerciseImage(name: 'Weighted Seated Calf Raise', imagePath: 'assets/exercise_images/Calf/Weighted-Seated-Calf-Raise.gif', muscleGroup: 'Calf', fileName: 'Weighted-Seated-Calf-Raise.gif'),
    ];
  }

  // Forearm exercises (32 exercises)
  static List<ExerciseImage> _getForearmExercises() {
    return [
      const ExerciseImage(name: 'Barbell Finger Curl', imagePath: 'assets/exercise_images/Forearm/Barbell-Finger-Curl.gif', muscleGroup: 'Forearm', fileName: 'Barbell-Finger-Curl.gif'),
      const ExerciseImage(name: 'Barbell Reverse Curl', imagePath: 'assets/exercise_images/Forearm/Barbell-Reverse-Curl.gif', muscleGroup: 'Forearm', fileName: 'Barbell-Reverse-Curl.gif'),
      const ExerciseImage(name: 'Barbell Reverse Wrist Curl Over Bench', imagePath: 'assets/exercise_images/Forearm/Barbell-Reverse-Wrist-Curl-Over-a-Bench.gif', muscleGroup: 'Forearm', fileName: 'Barbell-Reverse-Wrist-Curl-Over-a-Bench.gif'),
      const ExerciseImage(name: 'Barbell Reverse Wrist Curl', imagePath: 'assets/exercise_images/Forearm/Barbell-Reverse-Wrist-Curl.gif', muscleGroup: 'Forearm', fileName: 'Barbell-Reverse-Wrist-Curl.gif'),
      const ExerciseImage(name: 'Barbell Wrist Curl', imagePath: 'assets/exercise_images/Forearm/barbell-Wrist-Curl.gif', muscleGroup: 'Forearm', fileName: 'barbell-Wrist-Curl.gif'),
      const ExerciseImage(name: 'Behind The Back Barbell Wrist Curl', imagePath: 'assets/exercise_images/Forearm/Behind-The-Back-Barbell-Wrist-Curl.gif', muscleGroup: 'Forearm', fileName: 'Behind-The-Back-Barbell-Wrist-Curl.gif'),
      const ExerciseImage(name: 'Cable One Arm Wrist Curl On Floor', imagePath: 'assets/exercise_images/Forearm/Cable-One-Arm-Wrist-Curl-On-Floor.gif', muscleGroup: 'Forearm', fileName: 'Cable-One-Arm-Wrist-Curl-On-Floor.gif'),
      const ExerciseImage(name: 'Cable Reverse Grip EZ-bar Biceps Curl', imagePath: 'assets/exercise_images/Forearm/Cable-Reverse-Grip-EZ-bar-Biceps-Curl.gif', muscleGroup: 'Forearm', fileName: 'Cable-Reverse-Grip-EZ-bar-Biceps-Curl.gif'),
      const ExerciseImage(name: 'Cable Single Arm Hammer Curl', imagePath: 'assets/exercise_images/Forearm/cable-single-arm-hammer-curl.gif', muscleGroup: 'Forearm', fileName: 'cable-single-arm-hammer-curl.gif'),
      const ExerciseImage(name: 'Dumbbell Finger Curl', imagePath: 'assets/exercise_images/Forearm/Dumbbell-Finger-Curl.gif', muscleGroup: 'Forearm', fileName: 'Dumbbell-Finger-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell Preacher Hammer Curl', imagePath: 'assets/exercise_images/Forearm/Dumbbell-Preacher-Hammer-Curl.gif', muscleGroup: 'Forearm', fileName: 'Dumbbell-Preacher-Hammer-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell Reverse Curl', imagePath: 'assets/exercise_images/Forearm/dumbbell-reverse-curl.gif', muscleGroup: 'Forearm', fileName: 'dumbbell-reverse-curl.gif'),
      const ExerciseImage(name: 'Dumbbell Scott Hammer Curl', imagePath: 'assets/exercise_images/Forearm/Dumbbell-Scott-Hammer-Curl.gif', muscleGroup: 'Forearm', fileName: 'Dumbbell-Scott-Hammer-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell Seated Neutral Wrist Curl', imagePath: 'assets/exercise_images/Forearm/Dumbbell-Seated-Neutral-Wrist-Curl.gif', muscleGroup: 'Forearm', fileName: 'Dumbbell-Seated-Neutral-Wrist-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell Wrist Curl', imagePath: 'assets/exercise_images/Forearm/Dumbbell-Wrist-Curl.gif', muscleGroup: 'Forearm', fileName: 'Dumbbell-Wrist-Curl.gif'),
      const ExerciseImage(name: 'Hammer Curl With Resistance Band', imagePath: 'assets/exercise_images/Forearm/Hammer-Curl-with-Resistance-Band.gif', muscleGroup: 'Forearm', fileName: 'Hammer-Curl-with-Resistance-Band.gif'),
      const ExerciseImage(name: 'Hand Gripper', imagePath: 'assets/exercise_images/Forearm/Hand-Gripper.gif', muscleGroup: 'Forearm', fileName: 'Hand-Gripper.gif'),
      const ExerciseImage(name: 'Reverse Grip EZ-Bar Curl', imagePath: 'assets/exercise_images/Forearm/Reverse-Grip-EZ-Bar-Curl.gif', muscleGroup: 'Forearm', fileName: 'Reverse-Grip-EZ-Bar-Curl.gif'),
      const ExerciseImage(name: 'Reverse Wrist Curl', imagePath: 'assets/exercise_images/Forearm/Reverse-Wrist-Curl.gif', muscleGroup: 'Forearm', fileName: 'Reverse-Wrist-Curl.gif'),
      const ExerciseImage(name: 'Reverse Wrist Stretch', imagePath: 'assets/exercise_images/Forearm/reverse-Wrist-Stretch.gif', muscleGroup: 'Forearm', fileName: 'reverse-Wrist-Stretch.gif'),
      const ExerciseImage(name: 'Seated Barbell Finger Curl', imagePath: 'assets/exercise_images/Forearm/seated-barbell-finger-curl.gif', muscleGroup: 'Forearm', fileName: 'seated-barbell-finger-curl.gif'),
      const ExerciseImage(name: 'Seated Hammer Curl', imagePath: 'assets/exercise_images/Forearm/Seated-Hammer-Curl.gif', muscleGroup: 'Forearm', fileName: 'Seated-Hammer-Curl.gif'),
      const ExerciseImage(name: 'Seated Zottman Curl', imagePath: 'assets/exercise_images/Forearm/Seated-Zottman-Curl.gif', muscleGroup: 'Forearm', fileName: 'Seated-Zottman-Curl.gif'),
      const ExerciseImage(name: 'Single Arm Reverse Grip Cable Bicep Curl', imagePath: 'assets/exercise_images/Forearm/Single-Arm-Reverse-Grip-Cable-Bicep-Curl.gif', muscleGroup: 'Forearm', fileName: 'Single-Arm-Reverse-Grip-Cable-Bicep-Curl.gif'),
      const ExerciseImage(name: 'Single Dumbbell Spider Hammer Curl', imagePath: 'assets/exercise_images/Forearm/Single-Dumbbell-Spider-Hammer-Curl.gif', muscleGroup: 'Forearm', fileName: 'Single-Dumbbell-Spider-Hammer-Curl.gif'),
      const ExerciseImage(name: 'Standing One Arm Chest Stretch', imagePath: 'assets/exercise_images/Forearm/Standing-one-arm-chest-stretch.gif', muscleGroup: 'Forearm', fileName: 'Standing-one-arm-chest-stretch.gif'),
      const ExerciseImage(name: 'Water Bottle Hammer Curl', imagePath: 'assets/exercise_images/Forearm/Water-Bottle-Hammer-Curl.gif', muscleGroup: 'Forearm', fileName: 'Water-Bottle-Hammer-Curl.gif'),
      const ExerciseImage(name: 'Weighted Wrist Curl', imagePath: 'assets/exercise_images/Forearm/Weighted-Wrist-Curl.gif', muscleGroup: 'Forearm', fileName: 'Weighted-Wrist-Curl.gif'),
      const ExerciseImage(name: 'Wrist Circles Stretch', imagePath: 'assets/exercise_images/Forearm/Wrist-Circles-Stretch.gif', muscleGroup: 'Forearm', fileName: 'Wrist-Circles-Stretch.gif'),
      const ExerciseImage(name: 'Wrist Roller', imagePath: 'assets/exercise_images/Forearm/wrist-roller.gif', muscleGroup: 'Forearm', fileName: 'wrist-roller.gif'),
      const ExerciseImage(name: 'Wrist Rotations', imagePath: 'assets/exercise_images/Forearm/wrist-rotations.gif', muscleGroup: 'Forearm', fileName: 'wrist-rotations.gif'),
      const ExerciseImage(name: 'Wrist Stretch', imagePath: 'assets/exercise_images/Forearm/Wrist-Stretch.gif', muscleGroup: 'Forearm', fileName: 'Wrist-Stretch.gif'),
      const ExerciseImage(name: 'Wrist Ulnar Deviator And Extensor Stretch', imagePath: 'assets/exercise_images/Forearm/Wrist-Ulnar-Deviator-And-Extensor-Stretch.gif', muscleGroup: 'Forearm', fileName: 'Wrist-Ulnar-Deviator-And-Extensor-Stretch.gif'),
    ];
  }

  // Hip exercises (26 exercises)
  static List<ExerciseImage> _getHipExercises() {
    return [
      const ExerciseImage(name: 'Ab Wheel Rollout', imagePath: 'assets/exercise_images/Hips/Ab-Wheel-Rollout.gif', muscleGroup: 'Hips', fileName: 'Ab-Wheel-Rollout.gif'),
      const ExerciseImage(name: 'Band Lying Hip External Rotation', imagePath: 'assets/exercise_images/Hips/Band-Lying-Hip-External-Rotation.gif', muscleGroup: 'Hips', fileName: 'Band-Lying-Hip-External-Rotation.gif'),
      const ExerciseImage(name: 'Band Seated Hip External Rotation', imagePath: 'assets/exercise_images/Hips/Band-Seated-Hip-External-Rotation.gif', muscleGroup: 'Hips', fileName: 'Band-Seated-Hip-External-Rotation.gif'),
      const ExerciseImage(name: 'Band Seated Hip Internal Rotation', imagePath: 'assets/exercise_images/Hips/Band-Seated-Hip-Internal-Rotation.gif', muscleGroup: 'Hips', fileName: 'Band-Seated-Hip-Internal-Rotation.gif'),
      const ExerciseImage(name: 'Band Side Lying Clam', imagePath: 'assets/exercise_images/Hips/Band-Side-Lying-Clam.gif', muscleGroup: 'Hips', fileName: 'Band-Side-Lying-Clam.gif'),
      const ExerciseImage(name: 'Barbell Glute Bridge Two Legs On Bench', imagePath: 'assets/exercise_images/Hips/Barbell-Glute-Bridge-Two-Legs-on-Bench.gif', muscleGroup: 'Hips', fileName: 'Barbell-Glute-Bridge-Two-Legs-on-Bench.gif'),
      const ExerciseImage(name: 'Barbell Glute Bridge', imagePath: 'assets/exercise_images/Hips/Barbell-Glute-Bridge.gif', muscleGroup: 'Hips', fileName: 'Barbell-Glute-Bridge.gif'),
      const ExerciseImage(name: 'Barbell Single Leg Hip Thrust', imagePath: 'assets/exercise_images/Hips/Barbell-Single-Leg-Hip-Thrust.gif', muscleGroup: 'Hips', fileName: 'Barbell-Single-Leg-Hip-Thrust.gif'),
      const ExerciseImage(name: 'Bench Glute Flutter Kicks', imagePath: 'assets/exercise_images/Hips/Bench-Glute-Flutter-Kicks.gif', muscleGroup: 'Hips', fileName: 'Bench-Glute-Flutter-Kicks.gif'),
      const ExerciseImage(name: 'Cable Hip Extension', imagePath: 'assets/exercise_images/Hips/Cable-Hip-Extension.gif', muscleGroup: 'Hips', fileName: 'Cable-Hip-Extension.gif'),
      const ExerciseImage(name: 'Cable Kneeling Pull Through', imagePath: 'assets/exercise_images/Hips/Cable-Kneeling-Pull-Through.gif', muscleGroup: 'Hips', fileName: 'Cable-Kneeling-Pull-Through.gif'),
      const ExerciseImage(name: 'Cable Pull Through', imagePath: 'assets/exercise_images/Hips/Cable-Pull-Through.gif', muscleGroup: 'Hips', fileName: 'Cable-Pull-Through.gif'),
      const ExerciseImage(name: 'Duck Walk', imagePath: 'assets/exercise_images/Hips/Duck-Walk (1).gif', muscleGroup: 'Hips', fileName: 'Duck-Walk (1).gif'),
      const ExerciseImage(name: 'Dumbbell Glute Bridge', imagePath: 'assets/exercise_images/Hips/Dumbbell-Glute-Bridge.gif', muscleGroup: 'Hips', fileName: 'Dumbbell-Glute-Bridge.gif'),
      const ExerciseImage(name: 'Glute Kickback Machine', imagePath: 'assets/exercise_images/Hips/Glute-Kickback-Machine.gif', muscleGroup: 'Hips', fileName: 'Glute-Kickback-Machine.gif'),
      const ExerciseImage(name: 'Hip Extension On Bench', imagePath: 'assets/exercise_images/Hips/Hip-Extension-On-Bench.gif', muscleGroup: 'Hips', fileName: 'Hip-Extension-On-Bench.gif'),
      const ExerciseImage(name: 'Lever Standing Rear Kick', imagePath: 'assets/exercise_images/Hips/Lever-Standing-Rear-Kick.gif', muscleGroup: 'Hips', fileName: 'Lever-Standing-Rear-Kick.gif'),
      const ExerciseImage(name: 'Pendulum Squat', imagePath: 'assets/exercise_images/Hips/Pendulum-Squat.gif', muscleGroup: 'Hips', fileName: 'Pendulum-Squat.gif'),
      const ExerciseImage(name: 'Pvc Hip Hinge', imagePath: 'assets/exercise_images/Hips/Pvc-Hip-Hinge.gif', muscleGroup: 'Hips', fileName: 'Pvc-Hip-Hinge.gif'),
      const ExerciseImage(name: 'Resistance Band Reverse Hyperextension', imagePath: 'assets/exercise_images/Hips/Resistance-Band-Reverse-Hyperextension.gif', muscleGroup: 'Hips', fileName: 'Resistance-Band-Reverse-Hyperextension.gif'),
      const ExerciseImage(name: 'Reverse Plank', imagePath: 'assets/exercise_images/Hips/Reverse-plank.gif', muscleGroup: 'Hips', fileName: 'Reverse-plank.gif'),
      const ExerciseImage(name: 'Side Hip Abduction', imagePath: 'assets/exercise_images/Hips/Side-Hip-Abduction.gif', muscleGroup: 'Hips', fileName: 'Side-Hip-Abduction.gif'),
      const ExerciseImage(name: 'Side Lying Hip Adduction', imagePath: 'assets/exercise_images/Hips/Side-Lying-Hip-Adduction.gif', muscleGroup: 'Hips', fileName: 'Side-Lying-Hip-Adduction.gif'),
      const ExerciseImage(name: 'Side Plank Hip Adduction Copenhagen Adduction', imagePath: 'assets/exercise_images/Hips/Side-Plank-Hip-Adduction-Copenhagen-adduction.gif', muscleGroup: 'Hips', fileName: 'Side-Plank-Hip-Adduction-Copenhagen-adduction.gif'),
      const ExerciseImage(name: 'Single Leg Dumbbell Hip Thrust', imagePath: 'assets/exercise_images/Hips/Single-Leg-Dumbbell-Hip-Thrust.gif', muscleGroup: 'Hips', fileName: 'Single-Leg-Dumbbell-Hip-Thrust.gif'),
      const ExerciseImage(name: 'Single Leg Hip Thrust Jump', imagePath: 'assets/exercise_images/Hips/Single-Leg-Hip-Thrust-Jump.gif', muscleGroup: 'Hips', fileName: 'Single-Leg-Hip-Thrust-Jump.gif'),
      const ExerciseImage(name: 'Stiff Leg Deadlift', imagePath: 'assets/exercise_images/Hips/Stiff-Leg-Deadlift (1).gif', muscleGroup: 'Hips', fileName: 'Stiff-Leg-Deadlift (1).gif'),
    ];
  }

  // Leg exercises
  static List<ExerciseImage> _getLegExercises() {
    return [
      const ExerciseImage(name: '5 Dot Drills Agility Exercise', imagePath: 'assets/exercise_images/Leg/5-Dot-drills-agility-exercise.gif', muscleGroup: 'Leg', fileName: '5-Dot-drills-agility-exercise.gif'),
      const ExerciseImage(name: '90 90 Hip Stretch', imagePath: 'assets/exercise_images/Leg/90-90-Hip-Stretch.gif', muscleGroup: 'Leg', fileName: '90-90-Hip-Stretch.gif'),
      const ExerciseImage(name: 'ATG Split Squat', imagePath: 'assets/exercise_images/Leg/ATG-Split-Squat.gif', muscleGroup: 'Leg', fileName: 'ATG-Split-Squat.gif'),
      const ExerciseImage(name: 'All Fours Squad Stretch', imagePath: 'assets/exercise_images/Leg/All-Fours-Squad-Stretch.gif', muscleGroup: 'Leg', fileName: 'All-Fours-Squad-Stretch.gif'),
      const ExerciseImage(name: 'Barbell Squat', imagePath: 'assets/exercise_images/Leg/BARBELL-SQUAT.gif', muscleGroup: 'Leg', fileName: 'BARBELL-SQUAT.gif'),
      const ExerciseImage(name: 'Backward Jumping', imagePath: 'assets/exercise_images/Leg/Backward-Jumping.gif', muscleGroup: 'Leg', fileName: 'Backward-Jumping.gif'),
      const ExerciseImage(name: 'Banded Step Up', imagePath: 'assets/exercise_images/Leg/Banded-Step-up.gif', muscleGroup: 'Leg', fileName: 'Banded-Step-up.gif'),
      const ExerciseImage(name: 'Barbell Bench Front Squat', imagePath: 'assets/exercise_images/Leg/Barbell-Bench-Front-Squat.gif', muscleGroup: 'Leg', fileName: 'Barbell-Bench-Front-Squat.gif'),
      const ExerciseImage(name: 'Barbell Bulgarian Split Squat', imagePath: 'assets/exercise_images/Leg/Barbell-Bulgarian-Split-Squat.gif', muscleGroup: 'Leg', fileName: 'Barbell-Bulgarian-Split-Squat.gif'),
      const ExerciseImage(name: 'Barbell Curtsey Lunge', imagePath: 'assets/exercise_images/Leg/Barbell-Curtsey-Lunge.gif', muscleGroup: 'Leg', fileName: 'Barbell-Curtsey-Lunge.gif'),
      const ExerciseImage(name: 'Barbell Deadlift', imagePath: 'assets/exercise_images/Leg/Barbell-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Barbell-Deadlift.gif'),
      const ExerciseImage(name: 'Barbell Good Morning', imagePath: 'assets/exercise_images/Leg/Barbell-Good-Morning.gif', muscleGroup: 'Leg', fileName: 'Barbell-Good-Morning.gif'),
      const ExerciseImage(name: 'Barbell Hack Squat', imagePath: 'assets/exercise_images/Leg/Barbell-Hack-Squat.gif', muscleGroup: 'Leg', fileName: 'Barbell-Hack-Squat.gif'),
      const ExerciseImage(name: 'Barbell Jump Squat', imagePath: 'assets/exercise_images/Leg/Barbell-Jump-Squat.gif', muscleGroup: 'Leg', fileName: 'Barbell-Jump-Squat.gif'),
      const ExerciseImage(name: 'Barbell Lateral Lunge', imagePath: 'assets/exercise_images/Leg/Barbell-Lateral-Lunge.gif', muscleGroup: 'Leg', fileName: 'Barbell-Lateral-Lunge.gif'),
      const ExerciseImage(name: 'Barbell Lunge', imagePath: 'assets/exercise_images/Leg/Barbell-Lunge.gif', muscleGroup: 'Leg', fileName: 'Barbell-Lunge.gif'),
      const ExerciseImage(name: 'Barbell Pin Squat', imagePath: 'assets/exercise_images/Leg/Barbell-Pin-Squat.gif', muscleGroup: 'Leg', fileName: 'Barbell-Pin-Squat.gif'),
      const ExerciseImage(name: 'Barbell Single Leg Deadlift', imagePath: 'assets/exercise_images/Leg/Barbell-Single-Leg-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Barbell-Single-Leg-Deadlift.gif'),
      const ExerciseImage(name: 'Barbell Split Squat', imagePath: 'assets/exercise_images/Leg/Barbell-Split-Squat.gif', muscleGroup: 'Leg', fileName: 'Barbell-Split-Squat.gif'),
      const ExerciseImage(name: 'Barbell Sumo Squat', imagePath: 'assets/exercise_images/Leg/Barbell-sumo-squat.gif', muscleGroup: 'Leg', fileName: 'Barbell-sumo-squat.gif'),
      const ExerciseImage(name: 'Bodyweight Kneeling Sissy Squat', imagePath: 'assets/exercise_images/Leg/Bodyweight-Kneeling-Sissy-Squat.gif', muscleGroup: 'Leg', fileName: 'Bodyweight-Kneeling-Sissy-Squat.gif'),
      const ExerciseImage(name: 'Bodyweight Plie Squat', imagePath: 'assets/exercise_images/Leg/Bodyweight-Plie-Squat.gif', muscleGroup: 'Leg', fileName: 'Bodyweight-Plie-Squat.gif'),
      const ExerciseImage(name: 'Bow Yoga Pose', imagePath: 'assets/exercise_images/Leg/Bow-Yoga-Pose.gif', muscleGroup: 'Leg', fileName: 'Bow-Yoga-Pose.gif'),
      const ExerciseImage(name: 'Box Jump 1 To 2', imagePath: 'assets/exercise_images/Leg/Box-Jump-1-to-2.gif', muscleGroup: 'Leg', fileName: 'Box-Jump-1-to-2.gif'),
      const ExerciseImage(name: 'Box Jump 2 To 1', imagePath: 'assets/exercise_images/Leg/Box-Jump-2-to-1.gif', muscleGroup: 'Leg', fileName: 'Box-Jump-2-to-1.gif'),
      const ExerciseImage(name: 'Box Jump To Pistol Squat', imagePath: 'assets/exercise_images/Leg/Box-Jump-to-Pistol-Squat.gif', muscleGroup: 'Leg', fileName: 'Box-Jump-to-Pistol-Squat.gif'),
      const ExerciseImage(name: 'Box Pistol Squat', imagePath: 'assets/exercise_images/Leg/Box-pistol-Squat.gif', muscleGroup: 'Leg', fileName: 'Box-pistol-Squat.gif'),
      const ExerciseImage(name: 'Bulgarian Jump Squat', imagePath: 'assets/exercise_images/Leg/Bulgarian-Jump-Squat.gif', muscleGroup: 'Leg', fileName: 'Bulgarian-Jump-Squat.gif'),
      const ExerciseImage(name: 'Butterfly Stretch', imagePath: 'assets/exercise_images/Leg/Butterfly-Stretch.gif', muscleGroup: 'Leg', fileName: 'Butterfly-Stretch.gif'),
      const ExerciseImage(name: 'Cable Forward Lunge', imagePath: 'assets/exercise_images/Leg/Cable-Forward-Lunge.gif', muscleGroup: 'Leg', fileName: 'Cable-Forward-Lunge.gif'),
      const ExerciseImage(name: 'Cable Front Squat', imagePath: 'assets/exercise_images/Leg/Cable-Front-Squat.gif', muscleGroup: 'Leg', fileName: 'Cable-Front-Squat.gif'),
      const ExerciseImage(name: 'Cable Lunge', imagePath: 'assets/exercise_images/Leg/Cable-Lunge.gif', muscleGroup: 'Leg', fileName: 'Cable-Lunge.gif'),
      const ExerciseImage(name: 'Crouching Heel Back Calf Stretch', imagePath: 'assets/exercise_images/Leg/Crouching-Heel-Back-Calf-Stretch.gif', muscleGroup: 'Leg', fileName: 'Crouching-Heel-Back-Calf-Stretch.gif'),
      const ExerciseImage(name: 'Curtsey Squat', imagePath: 'assets/exercise_images/Leg/Curtsey-Squat.gif', muscleGroup: 'Leg', fileName: 'Curtsey-Squat.gif'),
      const ExerciseImage(name: 'Decline Bench Dumbbell Lunge', imagePath: 'assets/exercise_images/Leg/Decline-Bench-Dumbbell-Lunge.gif', muscleGroup: 'Leg', fileName: 'Decline-Bench-Dumbbell-Lunge.gif'),
      const ExerciseImage(name: 'Decline Dumbbell Leg Curl', imagePath: 'assets/exercise_images/Leg/Decline-Dumbbell-Leg-Curl.gif', muscleGroup: 'Leg', fileName: 'Decline-Dumbbell-Leg-Curl.gif'),
      const ExerciseImage(name: 'Depth Jump To Hurdle Hop', imagePath: 'assets/exercise_images/Leg/Depth-Jump-to-Hurdle-Hop.gif', muscleGroup: 'Leg', fileName: 'Depth-Jump-to-Hurdle-Hop.gif'),
      const ExerciseImage(name: 'Duck Walk', imagePath: 'assets/exercise_images/Leg/Duck-Walk.gif', muscleGroup: 'Leg', fileName: 'Duck-Walk.gif'),
      const ExerciseImage(name: 'Dumbbell Goblet Curtsey Lunge', imagePath: 'assets/exercise_images/Leg/Dumbbell-Goblet-Curtsey-Lunge.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Goblet-Curtsey-Lunge.gif'),
      const ExerciseImage(name: 'Dumbbell Goblet Squat', imagePath: 'assets/exercise_images/Leg/Dumbbell-Goblet-Squat.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Goblet-Squat.gif'),
      const ExerciseImage(name: 'Dumbbell Good Morning', imagePath: 'assets/exercise_images/Leg/Dumbbell-Good-Morning.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Good-Morning.gif'),
      const ExerciseImage(name: 'Dumbbell Jump Squat', imagePath: 'assets/exercise_images/Leg/Dumbbell-Jump-Squat.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Jump-Squat.gif'),
      const ExerciseImage(name: 'Dumbbell Pull Through', imagePath: 'assets/exercise_images/Leg/Dumbbell-Pull-Through.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Pull-Through.gif'),
      const ExerciseImage(name: 'Dumbbell Rear Lunge', imagePath: 'assets/exercise_images/Leg/Dumbbell-Rear-Lunge.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Rear-Lunge.gif'),
      const ExerciseImage(name: 'Dumbbell Single Leg Deadlift', imagePath: 'assets/exercise_images/Leg/Dumbbell-Single-Leg-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Single-Leg-Deadlift.gif'),
      const ExerciseImage(name: 'Dumbbell Split Jump', imagePath: 'assets/exercise_images/Leg/Dumbbell-Split-Jump.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Split-Jump.gif'),
      const ExerciseImage(name: 'Dumbbell Squat', imagePath: 'assets/exercise_images/Leg/Dumbbell-Squat.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Squat.gif'),
      const ExerciseImage(name: 'Dumbbell Straight Leg Deadlift', imagePath: 'assets/exercise_images/Leg/Dumbbell-Straight-Leg-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-Straight-Leg-Deadlift.gif'),
      const ExerciseImage(name: 'Dumbbell Jefferson Curl', imagePath: 'assets/exercise_images/Leg/Dumbbell-jefferson-curl.gif', muscleGroup: 'Leg', fileName: 'Dumbbell-jefferson-curl.gif'),
      const ExerciseImage(name: 'Dumbeel Step Up', imagePath: 'assets/exercise_images/Leg/Dumbeel-Step-Up.gif', muscleGroup: 'Leg', fileName: 'Dumbeel-Step-Up.gif'),
      const ExerciseImage(name: 'Exercise Ball Wall Squat', imagePath: 'assets/exercise_images/Leg/Exercise-Ball-Wall-Squat.gif', muscleGroup: 'Leg', fileName: 'Exercise-Ball-Wall-Squat.gif'),
      const ExerciseImage(name: 'Foam Roller IT Iliotibial Band Stretch', imagePath: 'assets/exercise_images/Leg/Foam-Roller-IT-iliotibial-Band-Stretch.gif', muscleGroup: 'Leg', fileName: 'Foam-Roller-IT-iliotibial-Band-Stretch.gif'),
      const ExerciseImage(name: 'Foam Roller Plantar Fasciitis', imagePath: 'assets/exercise_images/Leg/Foam-Roller-Plantar-Fasciitis.gif', muscleGroup: 'Leg', fileName: 'Foam-Roller-Plantar-Fasciitis.gif'),
      const ExerciseImage(name: 'Foam Roller Quads', imagePath: 'assets/exercise_images/Leg/Foam-Roller-Quads.gif', muscleGroup: 'Leg', fileName: 'Foam-Roller-Quads.gif'),
      const ExerciseImage(name: 'Glute Ham Raise', imagePath: 'assets/exercise_images/Leg/Glute-Ham-Raise.gif', muscleGroup: 'Leg', fileName: 'Glute-Ham-Raise.gif'),
      const ExerciseImage(name: 'Good Morning With Resistance Band', imagePath: 'assets/exercise_images/Leg/Good-Morning-With-Resistance-Band.gif', muscleGroup: 'Leg', fileName: 'Good-Morning-With-Resistance-Band.gif'),
      const ExerciseImage(name: 'Heel Elevated Goblet Squat', imagePath: 'assets/exercise_images/Leg/Heel-Elevated-Goblet-Squat.gif', muscleGroup: 'Leg', fileName: 'Heel-Elevated-Goblet-Squat.gif'),
      const ExerciseImage(name: 'Heel Touch Side Kick Squat', imagePath: 'assets/exercise_images/Leg/Heel-Touch-Side-Kick-Squat.gif', muscleGroup: 'Leg', fileName: 'Heel-Touch-Side-Kick-Squat.gif'),
      const ExerciseImage(name: 'Hell Slide', imagePath: 'assets/exercise_images/Leg/Hell-Slide.gif', muscleGroup: 'Leg', fileName: 'Hell-Slide.gif'),
      const ExerciseImage(name: 'High Knee Lunge On Bosu Ball', imagePath: 'assets/exercise_images/Leg/High-Knee-Lunge-on-Bosu-Ball.gif', muscleGroup: 'Leg', fileName: 'High-Knee-Lunge-on-Bosu-Ball.gif'),
      const ExerciseImage(name: 'High Knee Run', imagePath: 'assets/exercise_images/Leg/High-Knee-Run.gif', muscleGroup: 'Leg', fileName: 'High-Knee-Run.gif'),
      const ExerciseImage(name: 'High Knee Squat', imagePath: 'assets/exercise_images/Leg/High-Knee-Squat.gif', muscleGroup: 'Leg', fileName: 'High-Knee-Squat.gif'),
      const ExerciseImage(name: 'Jumping Jack', imagePath: 'assets/exercise_images/Leg/Jumping-jack.gif', muscleGroup: 'Leg', fileName: 'Jumping-jack.gif'),
      const ExerciseImage(name: 'Kettlebell Pistol Squats', imagePath: 'assets/exercise_images/Leg/Kettlebell-Pistol-Squats.gif', muscleGroup: 'Leg', fileName: 'Kettlebell-Pistol-Squats.gif'),
      const ExerciseImage(name: 'Kettlebell Front Squat', imagePath: 'assets/exercise_images/Leg/Kettlebell-front-squat.gif', muscleGroup: 'Leg', fileName: 'Kettlebell-front-squat.gif'),
      const ExerciseImage(name: 'Knee Circles', imagePath: 'assets/exercise_images/Leg/Knee-Circles.gif', muscleGroup: 'Leg', fileName: 'Knee-Circles.gif'),
      const ExerciseImage(name: 'Kneeling Hip Flexor Stretch', imagePath: 'assets/exercise_images/Leg/Kneeling-Hip-Flexor-Stretch.gif', muscleGroup: 'Leg', fileName: 'Kneeling-Hip-Flexor-Stretch.gif'),
      const ExerciseImage(name: 'Kneeling Jump Squat', imagePath: 'assets/exercise_images/Leg/Kneeling-Jump-Squat.gif', muscleGroup: 'Leg', fileName: 'Kneeling-Jump-Squat.gif'),
      const ExerciseImage(name: 'Leg Extension', imagePath: 'assets/exercise_images/Leg/LEG-EXTENSION.gif', muscleGroup: 'Leg', fileName: 'LEG-EXTENSION.gif'),
      const ExerciseImage(name: 'Landmine Deadlift', imagePath: 'assets/exercise_images/Leg/Landmine-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Landmine-Deadlift.gif'),
      const ExerciseImage(name: 'Landmine Lunge', imagePath: 'assets/exercise_images/Leg/Landmine-Lunge.gif', muscleGroup: 'Leg', fileName: 'Landmine-Lunge.gif'),
      const ExerciseImage(name: 'Landmine Squat', imagePath: 'assets/exercise_images/Leg/Landmine-Squat.gif', muscleGroup: 'Leg', fileName: 'Landmine-Squat.gif'),
      const ExerciseImage(name: 'Lateral Leg Swings', imagePath: 'assets/exercise_images/Leg/Lateral-Leg-Swings.gif', muscleGroup: 'Leg', fileName: 'Lateral-Leg-Swings.gif'),
      const ExerciseImage(name: 'Leg Curl', imagePath: 'assets/exercise_images/Leg/Leg-Curl.gif', muscleGroup: 'Leg', fileName: 'Leg-Curl.gif'),
      const ExerciseImage(name: 'Leg Press', imagePath: 'assets/exercise_images/Leg/Leg-Press.gif', muscleGroup: 'Leg', fileName: 'Leg-Press.gif'),
      const ExerciseImage(name: 'Leg Swings Front To Back', imagePath: 'assets/exercise_images/Leg/Leg-Swings-Front-to-Back.gif', muscleGroup: 'Leg', fileName: 'Leg-Swings-Front-to-Back.gif'),
      const ExerciseImage(name: 'Lever Deadlift', imagePath: 'assets/exercise_images/Leg/Lever-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Lever-Deadlift.gif'),
      const ExerciseImage(name: 'Lever Horizontal Leg Press', imagePath: 'assets/exercise_images/Leg/Lever-Horizontal-Leg-Press.gif', muscleGroup: 'Leg', fileName: 'Lever-Horizontal-Leg-Press.gif'),
      const ExerciseImage(name: 'Lever Kneeling Leg Curl', imagePath: 'assets/exercise_images/Leg/Lever-Kneeling-Leg-Curl-.gif', muscleGroup: 'Leg', fileName: 'Lever-Kneeling-Leg-Curl-.gif'),
      const ExerciseImage(name: 'Lever Side Hip Adduction', imagePath: 'assets/exercise_images/Leg/Lever-Side-Hip-Adduction.gif', muscleGroup: 'Leg', fileName: 'Lever-Side-Hip-Adduction.gif'),
      const ExerciseImage(name: 'Lever Single Leg Curl', imagePath: 'assets/exercise_images/Leg/Lever-Single-Leg-Curl.gif', muscleGroup: 'Leg', fileName: 'Lever-Single-Leg-Curl.gif'),
      const ExerciseImage(name: 'Lever Standing Leg Raise', imagePath: 'assets/exercise_images/Leg/Lever-Standing-Leg-Raise.gif', muscleGroup: 'Leg', fileName: 'Lever-Standing-Leg-Raise.gif'),
      const ExerciseImage(name: 'Long Jump Plyometrics', imagePath: 'assets/exercise_images/Leg/Long-Jump-Plyometrics.gif', muscleGroup: 'Leg', fileName: 'Long-Jump-Plyometrics.gif'),
      const ExerciseImage(name: 'Lying Dumbbell Leg Curl', imagePath: 'assets/exercise_images/Leg/Lying-Dumbbell-Leg-Curl.gif', muscleGroup: 'Leg', fileName: 'Lying-Dumbbell-Leg-Curl.gif'),
      const ExerciseImage(name: 'Nordic Hamstring Curl', imagePath: 'assets/exercise_images/Leg/Nordic-Hamstring-Curl.gif', muscleGroup: 'Leg', fileName: 'Nordic-Hamstring-Curl.gif'),
      const ExerciseImage(name: 'Pin Squat', imagePath: 'assets/exercise_images/Leg/Pin-Squat.gif', muscleGroup: 'Leg', fileName: 'Pin-Squat.gif'),
      const ExerciseImage(name: 'Piriformis Stretch', imagePath: 'assets/exercise_images/Leg/Piriformis-Stretch.gif', muscleGroup: 'Leg', fileName: 'Piriformis-Stretch.gif'),
      const ExerciseImage(name: 'Pistol Squat To Box', imagePath: 'assets/exercise_images/Leg/Pistol-Squat-to-Box.gif', muscleGroup: 'Leg', fileName: 'Pistol-Squat-to-Box.gif'),
      const ExerciseImage(name: 'Resistance Band Overhead Squat', imagePath: 'assets/exercise_images/Leg/Resistance-Band-Overhead-Squat.gif', muscleGroup: 'Leg', fileName: 'Resistance-Band-Overhead-Squat.gif'),
      const ExerciseImage(name: 'Reverse Hack Squat', imagePath: 'assets/exercise_images/Leg/Reverse-Hack-Squat.gif', muscleGroup: 'Leg', fileName: 'Reverse-Hack-Squat.gif'),
      const ExerciseImage(name: 'Seated Adductor Groin Stretch', imagePath: 'assets/exercise_images/Leg/Seated-Adductor-Groin-Stretch.gif', muscleGroup: 'Leg', fileName: 'Seated-Adductor-Groin-Stretch.gif'),
      const ExerciseImage(name: 'Seated Hamstring Stretch', imagePath: 'assets/exercise_images/Leg/Seated-Hamstring-Stretch.gif', muscleGroup: 'Leg', fileName: 'Seated-Hamstring-Stretch.gif'),
      const ExerciseImage(name: 'Seated Leg Curl', imagePath: 'assets/exercise_images/Leg/Seated-Leg-Curl.gif', muscleGroup: 'Leg', fileName: 'Seated-Leg-Curl.gif'),
      const ExerciseImage(name: 'Seated Piriformis Stretch', imagePath: 'assets/exercise_images/Leg/Seated-Piriformis-Stretch.gif', muscleGroup: 'Leg', fileName: 'Seated-Piriformis-Stretch.gif'),
      const ExerciseImage(name: 'Seated Side Crunches', imagePath: 'assets/exercise_images/Leg/Seated-Side-Crunches.gif', muscleGroup: 'Leg', fileName: 'Seated-Side-Crunches.gif'),
      const ExerciseImage(name: 'Seated Toe Touches', imagePath: 'assets/exercise_images/Leg/Seated-Toe-Touches.gif', muscleGroup: 'Leg', fileName: 'Seated-Toe-Touches.gif'),
      const ExerciseImage(name: 'Single Leg Box Jump', imagePath: 'assets/exercise_images/Leg/Single-Leg-Box-Jump.gif', muscleGroup: 'Leg', fileName: 'Single-Leg-Box-Jump.gif'),
      const ExerciseImage(name: 'Single Leg Broad Jump', imagePath: 'assets/exercise_images/Leg/Single-Leg-Broad-Jump.gif', muscleGroup: 'Leg', fileName: 'Single-Leg-Broad-Jump.gif'),
      const ExerciseImage(name: 'Single Leg Extension', imagePath: 'assets/exercise_images/Leg/Single-Leg-Extension.gif', muscleGroup: 'Leg', fileName: 'Single-Leg-Extension.gif'),
      const ExerciseImage(name: 'Single Leg Step Down', imagePath: 'assets/exercise_images/Leg/Single-Leg-Step-Down.gif', muscleGroup: 'Leg', fileName: 'Single-Leg-Step-Down.gif'),
      const ExerciseImage(name: 'Sitting Wide Leg Adductor Stretch', imagePath: 'assets/exercise_images/Leg/Sitting-Wide-Leg-Adductor-Stretch.gif', muscleGroup: 'Leg', fileName: 'Sitting-Wide-Leg-Adductor-Stretch.gif'),
      const ExerciseImage(name: 'Skater', imagePath: 'assets/exercise_images/Leg/Skater.gif', muscleGroup: 'Leg', fileName: 'Skater.gif'),
      const ExerciseImage(name: 'Sled Hack Squat', imagePath: 'assets/exercise_images/Leg/Sled-Hack-Squat.gif', muscleGroup: 'Leg', fileName: 'Sled-Hack-Squat.gif'),
      const ExerciseImage(name: 'Smith Machine Good Morning', imagePath: 'assets/exercise_images/Leg/Smith-Machine-Good-Morning.gif', muscleGroup: 'Leg', fileName: 'Smith-Machine-Good-Morning.gif'),
      const ExerciseImage(name: 'Smith Machine Leg Press', imagePath: 'assets/exercise_images/Leg/Smith-Machine-Leg-Press.gif', muscleGroup: 'Leg', fileName: 'Smith-Machine-Leg-Press.gif'),
      const ExerciseImage(name: 'Squat Mobility Complex', imagePath: 'assets/exercise_images/Leg/Squat-mobility-Complex.gif', muscleGroup: 'Leg', fileName: 'Squat-mobility-Complex.gif'),
      const ExerciseImage(name: 'Standing Hamstring Stretch', imagePath: 'assets/exercise_images/Leg/Standing-Hamstring-Stretch.gif', muscleGroup: 'Leg', fileName: 'Standing-Hamstring-Stretch.gif'),
      const ExerciseImage(name: 'Standing Leg Circles', imagePath: 'assets/exercise_images/Leg/Standing-Leg-Circles.gif', muscleGroup: 'Leg', fileName: 'Standing-Leg-Circles.gif'),
      const ExerciseImage(name: 'Standing Quadriceps Stretch', imagePath: 'assets/exercise_images/Leg/Standing-Quadriceps-Stretch.gif', muscleGroup: 'Leg', fileName: 'Standing-Quadriceps-Stretch.gif'),
      const ExerciseImage(name: 'Standing Single Leg Curl Machine', imagePath: 'assets/exercise_images/Leg/Standing-Single-Leg-Curl-Machine.gif', muscleGroup: 'Leg', fileName: 'Standing-Single-Leg-Curl-Machine.gif'),
      const ExerciseImage(name: 'Static Lunge', imagePath: 'assets/exercise_images/Leg/Static-Lunge.gif', muscleGroup: 'Leg', fileName: 'Static-Lunge.gif'),
      const ExerciseImage(name: 'Step Up Single Leg Balance With Bicep Curl', imagePath: 'assets/exercise_images/Leg/Step-Up-Single-Leg-Balance-with-Bicep-Curl.gif', muscleGroup: 'Leg', fileName: 'Step-Up-Single-Leg-Balance-with-Bicep-Curl.gif'),
      const ExerciseImage(name: 'Stiff Leg Deadlift', imagePath: 'assets/exercise_images/Leg/Stiff-Leg-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Stiff-Leg-Deadlift.gif'),
      const ExerciseImage(name: 'Sumo Plie Dumbbell Squat', imagePath: 'assets/exercise_images/Leg/Sumo-Plie-Dumbbell-Squat.gif', muscleGroup: 'Leg', fileName: 'Sumo-Plie-Dumbbell-Squat.gif'),
      const ExerciseImage(name: 'Supported One Leg Standing Hip Flexor And Knee Extensor Stretch', imagePath: 'assets/exercise_images/Leg/Supported-One-Leg-Standing-Hip-Flexor-And-Knee-Extensor-Stretch.gif', muscleGroup: 'Leg', fileName: 'Supported-One-Leg-Standing-Hip-Flexor-And-Knee-Extensor-Stretch.gif'),
      const ExerciseImage(name: 'The Box Jump', imagePath: 'assets/exercise_images/Leg/The-Box-Jump.gif', muscleGroup: 'Leg', fileName: 'The-Box-Jump.gif'),
      const ExerciseImage(name: 'Towel Leg Curl', imagePath: 'assets/exercise_images/Leg/Towel-Leg-Curl.gif', muscleGroup: 'Leg', fileName: 'Towel-Leg-Curl.gif'),
      const ExerciseImage(name: 'Trap Bar Deadlift', imagePath: 'assets/exercise_images/Leg/Trap-Bar-Deadlift.gif', muscleGroup: 'Leg', fileName: 'Trap-Bar-Deadlift.gif'),
      const ExerciseImage(name: 'Wall Sit', imagePath: 'assets/exercise_images/Leg/Wall-Sit-238x360.png', muscleGroup: 'Leg', fileName: 'Wall-Sit-238x360.png'),
      const ExerciseImage(name: 'Weighted Front Plank', imagePath: 'assets/exercise_images/Leg/Weighted-Front-Plank.gif', muscleGroup: 'Leg', fileName: 'Weighted-Front-Plank.gif'),
      const ExerciseImage(name: 'Zercher Squat', imagePath: 'assets/exercise_images/Leg/Zercher-Squat.gif', muscleGroup: 'Leg', fileName: 'Zercher-Squat.gif'),
      const ExerciseImage(name: 'Zig Zag Hops Plyometric', imagePath: 'assets/exercise_images/Leg/Zig-Zag-Hops-Plyometric.gif', muscleGroup: 'Leg', fileName: 'Zig-Zag-Hops-Plyometric.gif'),
      const ExerciseImage(name: 'Barbell Rack Pull', imagePath: 'assets/exercise_images/Leg/barbell-rack-pull.gif', muscleGroup: 'Leg', fileName: 'barbell-rack-pull.gif'),
      const ExerciseImage(name: 'Belt Squat', imagePath: 'assets/exercise_images/Leg/belt-squat.gif', muscleGroup: 'Leg', fileName: 'belt-squat.gif'),
      const ExerciseImage(name: 'Bodyweight Lunges', imagePath: 'assets/exercise_images/Leg/bodyweight-lunges.gif', muscleGroup: 'Leg', fileName: 'bodyweight-lunges.gif'),
      const ExerciseImage(name: 'Bodyweight Reverse Lunge', imagePath: 'assets/exercise_images/Leg/bodyweight-reverse-lunge.gif', muscleGroup: 'Leg', fileName: 'bodyweight-reverse-lunge.gif'),
      const ExerciseImage(name: 'Bodyweight Squat Full Version', imagePath: 'assets/exercise_images/Leg/bodyweight-squat-full-version.gif', muscleGroup: 'Leg', fileName: 'bodyweight-squat-full-version.gif'),
      const ExerciseImage(name: 'Bodyweight Walking Lunge', imagePath: 'assets/exercise_images/Leg/bodyweight-walking-lunge.gif', muscleGroup: 'Leg', fileName: 'bodyweight-walking-lunge.gif'),
      const ExerciseImage(name: 'Curtsy Lunge', imagePath: 'assets/exercise_images/Leg/curtsy-lunge.gif', muscleGroup: 'Leg', fileName: 'curtsy-lunge.gif'),
      const ExerciseImage(name: 'Dumbbell Cossack Squat', imagePath: 'assets/exercise_images/Leg/dumbbell-cossack-squat.gif', muscleGroup: 'Leg', fileName: 'dumbbell-cossack-squat.gif'),
      const ExerciseImage(name: 'Dumbbell Deadlifts', imagePath: 'assets/exercise_images/Leg/dumbbell-deadlifts.gif', muscleGroup: 'Leg', fileName: 'dumbbell-deadlifts.gif'),
      const ExerciseImage(name: 'Dumbbell Lunges', imagePath: 'assets/exercise_images/Leg/dumbbell-lunges.gif', muscleGroup: 'Leg', fileName: 'dumbbell-lunges.gif'),
      const ExerciseImage(name: 'Dumbbell Sumo Deadlift', imagePath: 'assets/exercise_images/Leg/dumbbell-sumo-deadlift.gif', muscleGroup: 'Leg', fileName: 'dumbbell-sumo-deadlift.gif'),
      const ExerciseImage(name: 'Front Squat', imagePath: 'assets/exercise_images/Leg/front-squat.gif', muscleGroup: 'Leg', fileName: 'front-squat.gif'),
      const ExerciseImage(name: 'Hip Circles', imagePath: 'assets/exercise_images/Leg/hip-circles.gif', muscleGroup: 'Leg', fileName: 'hip-circles.gif'),
      const ExerciseImage(name: 'Jefferson Squat', imagePath: 'assets/exercise_images/Leg/jefferson-squat.gif', muscleGroup: 'Leg', fileName: 'jefferson-squat.gif'),
      const ExerciseImage(name: 'Pendulum Lunge', imagePath: 'assets/exercise_images/Leg/pendulum-lunge.gif', muscleGroup: 'Leg', fileName: 'pendulum-lunge.gif'),
      const ExerciseImage(name: 'Power Lunge', imagePath: 'assets/exercise_images/Leg/power-lunge.gif', muscleGroup: 'Leg', fileName: 'power-lunge.gif'),
      const ExerciseImage(name: 'Sissy Squat', imagePath: 'assets/exercise_images/Leg/sissy-squat.gif', muscleGroup: 'Leg', fileName: 'sissy-squat.gif'),
      const ExerciseImage(name: 'Smith Machine Squat', imagePath: 'assets/exercise_images/Leg/smith-machine-squat.gif', muscleGroup: 'Leg', fileName: 'smith-machine-squat.gif'),
      const ExerciseImage(name: 'Trap Bar Jump Squat', imagePath: 'assets/exercise_images/Leg/trap-bar-jump-squat.gif', muscleGroup: 'Leg', fileName: 'trap-bar-jump-squat.gif'),
      const ExerciseImage(name: 'Zercher Deadlift', imagePath: 'assets/exercise_images/Leg/zercher-deadlift.gif', muscleGroup: 'Leg', fileName: 'zercher-deadlift.gif'),
    ];
  }

  // Shoulder exercises - ALL actual exercises from the folder (130+ exercises)
  static List<ExerciseImage> _getShoulderExercises() {
    return [
      const ExerciseImage(name: '90 Degree Cable External Rotation', imagePath: 'assets/exercise_images/Shoulder/90-Degree-Cable-External-Rotation-.gif', muscleGroup: 'Shoulder', fileName: '90-Degree-Cable-External-Rotation-.gif'),
      const ExerciseImage(name: 'Across Chest Shoulder Stretch', imagePath: 'assets/exercise_images/Shoulder/Across-Chest-Shoulder-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Across-Chest-Shoulder-Stretch.gif'),
      const ExerciseImage(name: 'Alternate Dumbbell Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Alternate-Dumbbell-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Alternate-Dumbbell-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Alternating Dumbbell Front Raise', imagePath: 'assets/exercise_images/Shoulder/Alternating-Dumbbell-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Alternating-Dumbbell-Front-Raise.gif'),
      const ExerciseImage(name: 'Arm Circles', imagePath: 'assets/exercise_images/Shoulder/Arm-Circles_Shoulders.gif', muscleGroup: 'Shoulder', fileName: 'Arm-Circles_Shoulders.gif'),
      const ExerciseImage(name: 'Arm Scissors', imagePath: 'assets/exercise_images/Shoulder/Arm-Scissors.gif', muscleGroup: 'Shoulder', fileName: 'Arm-Scissors.gif'),
      const ExerciseImage(name: 'Arnold Press', imagePath: 'assets/exercise_images/Shoulder/Arnold-Press.gif', muscleGroup: 'Shoulder', fileName: 'Arnold-Press.gif'),
      const ExerciseImage(name: 'Back Lever', imagePath: 'assets/exercise_images/Shoulder/Back-Lever.gif', muscleGroup: 'Shoulder', fileName: 'Back-Lever.gif'),
      const ExerciseImage(name: 'Back Slaps Wrap Around Stretch', imagePath: 'assets/exercise_images/Shoulder/Back-Slaps-Wrap-Around-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Back-Slaps-Wrap-Around-Stretch.gif'),
      const ExerciseImage(name: 'Back To Wall Alternating Shoulder Flexion', imagePath: 'assets/exercise_images/Shoulder/Back-to-Wall-Alternating-Shoulder-Flexion.gif', muscleGroup: 'Shoulder', fileName: 'Back-to-Wall-Alternating-Shoulder-Flexion.gif'),
      const ExerciseImage(name: 'Backhand Raise', imagePath: 'assets/exercise_images/Shoulder/Backhand-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Backhand-Raise.gif'),
      const ExerciseImage(name: 'Band Front Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Band-Front-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Band-Front-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Band Single Arm Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Band-Single-Arm-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Band-Single-Arm-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Banded Shoulder Extension', imagePath: 'assets/exercise_images/Shoulder/Banded-Shoulder-Extension.gif', muscleGroup: 'Shoulder', fileName: 'Banded-Shoulder-Extension.gif'),
      const ExerciseImage(name: 'Banded Shoulder External Rotation', imagePath: 'assets/exercise_images/Shoulder/Banded-Shoulder-External-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Banded-Shoulder-External-Rotation.gif'),
      const ExerciseImage(name: 'Banded Shoulder Flexion', imagePath: 'assets/exercise_images/Shoulder/Banded-Shoulder-Flexion.gif', muscleGroup: 'Shoulder', fileName: 'Banded-Shoulder-Flexion.gif'),
      const ExerciseImage(name: 'Barbell Clean And Press', imagePath: 'assets/exercise_images/Shoulder/Barbell-Clean-and-Press-.gif', muscleGroup: 'Shoulder', fileName: 'Barbell-Clean-and-Press-.gif'),
      const ExerciseImage(name: 'Barbell Front Raise Twist', imagePath: 'assets/exercise_images/Shoulder/Barbell-Front-Raise-Twist.gif', muscleGroup: 'Shoulder', fileName: 'Barbell-Front-Raise-Twist.gif'),
      const ExerciseImage(name: 'Barbell Front Raise', imagePath: 'assets/exercise_images/Shoulder/Barbell-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Barbell-Front-Raise.gif'),
      const ExerciseImage(name: 'Barbell Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Barbell-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Barbell-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Barbell Standing Military Press', imagePath: 'assets/exercise_images/Shoulder/Barbell-Standing-Military-Press.gif', muscleGroup: 'Shoulder', fileName: 'Barbell-Standing-Military-Press.gif'),
      const ExerciseImage(name: 'Battle Rope', imagePath: 'assets/exercise_images/Shoulder/Battle-Rope.gif', muscleGroup: 'Shoulder', fileName: 'Battle-Rope.gif'),
      const ExerciseImage(name: 'Bench Pike Push Up', imagePath: 'assets/exercise_images/Shoulder/Bench-Pike-Push-up.gif', muscleGroup: 'Shoulder', fileName: 'Bench-Pike-Push-up.gif'),
      const ExerciseImage(name: 'Bench Supported Dumbbell External Rotation', imagePath: 'assets/exercise_images/Shoulder/Bench-Supported-Dumbbell-External-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Bench-Supported-Dumbbell-External-Rotation.gif'),
      const ExerciseImage(name: 'Bent Over Dumbbell Rear Delt Raise With Head On Bench', imagePath: 'assets/exercise_images/Shoulder/Bent-Over-Dumbbell-Rear-Delt-Raise-With-Head-On-Bench.gif', muscleGroup: 'Shoulder', fileName: 'Bent-Over-Dumbbell-Rear-Delt-Raise-With-Head-On-Bench.gif'),
      const ExerciseImage(name: 'Bent Over Row Gymstick', imagePath: 'assets/exercise_images/Shoulder/Bent-Over-Row-Gymstick.gif', muscleGroup: 'Shoulder', fileName: 'Bent-Over-Row-Gymstick.gif'),
      const ExerciseImage(name: 'Cable External Shoulder Rotation', imagePath: 'assets/exercise_images/Shoulder/Cable-External-Shoulder-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Cable-External-Shoulder-Rotation.gif'),
      const ExerciseImage(name: 'Cable Front Raise', imagePath: 'assets/exercise_images/Shoulder/Cable-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Cable-Front-Raise.gif'),
      const ExerciseImage(name: 'Cable Half Kneeling Pallof Press', imagePath: 'assets/exercise_images/Shoulder/Cable-Half-Kneeling-Pallof-Press.gif', muscleGroup: 'Shoulder', fileName: 'Cable-Half-Kneeling-Pallof-Press.gif'),
      const ExerciseImage(name: 'Cable Internal Shoulder Rotation', imagePath: 'assets/exercise_images/Shoulder/Cable-Internal-Shoulder-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Cable-Internal-Shoulder-Rotation.gif'),
      const ExerciseImage(name: 'Cable Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Cable-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Cable-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Cable Seated Shoulder Internal Rotation', imagePath: 'assets/exercise_images/Shoulder/Cable-Seated-Shoulder-Internal-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Cable-Seated-Shoulder-Internal-Rotation.gif'),
      const ExerciseImage(name: 'Cable Shoulder 90 Degrees Internal Rotation', imagePath: 'assets/exercise_images/Shoulder/Cable-Shoulder-90-degrees-Internal-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Cable-Shoulder-90-degrees-Internal-Rotation.gif'),
      const ExerciseImage(name: 'Cable Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Cable-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Cable-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Chest Supported Dumbbell Front Raises', imagePath: 'assets/exercise_images/Shoulder/Chest-Supported-Dumbbell-Front-Raises.gif', muscleGroup: 'Shoulder', fileName: 'Chest-Supported-Dumbbell-Front-Raises.gif'),
      const ExerciseImage(name: 'Chest And Front Of Shoulder Stretch', imagePath: 'assets/exercise_images/Shoulder/Chest-and-Front-of-Shoulder-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Chest-and-Front-of-Shoulder-Stretch.gif'),
      const ExerciseImage(name: 'Corner Wall Stretch', imagePath: 'assets/exercise_images/Shoulder/Corner-Wall-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Corner-Wall-Stretch.gif'),
      const ExerciseImage(name: 'Doorway Chest And Shoulder Stretch', imagePath: 'assets/exercise_images/Shoulder/Doorway-chest-and-sshoulder-stretch.gif', muscleGroup: 'Shoulder', fileName: 'Doorway-chest-and-sshoulder-stretch.gif'),
      const ExerciseImage(name: 'Double Cable Front Raise', imagePath: 'assets/exercise_images/Shoulder/Double-Cable-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Double-Cable-Front-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell 4 Ways Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-4-Ways-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-4-Ways-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell 6 Ways Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-6-Ways-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-6-Ways-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Bent Arm Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Bent-Arm-Laterl-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Bent-Arm-Laterl-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Chest Supported Lateral Raises', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Chest-Supported-Lateral-Raises.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Chest-Supported-Lateral-Raises.gif'),
      const ExerciseImage(name: 'Dumbbell Cuban External Rotation', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Cuban-External-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Cuban-External-Rotation.gif'),
      const ExerciseImage(name: 'Dumbbell Front Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Front-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Iron Cross', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Iron-Cross.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Iron-Cross.gif'),
      const ExerciseImage(name: 'Dumbbell Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Lateral To Front Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Lateral-to-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Lateral-to-Front-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Lying External Shoulder Rotation', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Lying-External-Shoulder-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Lying-External-Shoulder-Rotation.gif'),
      const ExerciseImage(name: 'Dumbbell Lying One Arm Rear Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Lying-One-Arm-Rear-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Lying-One-Arm-Rear-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Lying Rear Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Lying-Rear-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Lying-Rear-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell One Arm Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-One-Arm-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-One-Arm-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Dumbbell Push Press', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Push-Press.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Push-Press.gif'),
      const ExerciseImage(name: 'Dumbbell Rear Delt Row', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Rear-Delt-Row.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Rear-Delt-Row.gif'),
      const ExerciseImage(name: 'Dumbbell Scaption', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Scaption.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Scaption.gif'),
      const ExerciseImage(name: 'Dumbbell Seated Alternate Front Raises', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Seated-Alternate-Front-Raises.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Seated-Alternate-Front-Raises.gif'),
      const ExerciseImage(name: 'Dumbbell Seated Bent Over Rear Delt Row', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Seated-Bent-Over-Rear-Delt-Row.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Seated-Bent-Over-Rear-Delt-Row.gif'),
      const ExerciseImage(name: 'Dumbbell Seated Cuban Press', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Seated-Cuban-Press.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Seated-Cuban-Press.gif'),
      const ExerciseImage(name: 'Dumbbell Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Dumbbell Side Lying Rear Delt Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Side-Lying-Rear-Delt-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Side-Lying-Rear-Delt-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Single Arm Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Single-Arm-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Single-Arm-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Standing Palms In Press', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Standing-Palms-In-Press.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Standing-Palms-In-Press.gif'),
      const ExerciseImage(name: 'Dumbbell W Press', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-W-Press.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-W-Press.gif'),
      const ExerciseImage(name: 'Dumbbell Windmill', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Windmill.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Windmill.gif'),
      const ExerciseImage(name: 'Dumbbell Z Press', imagePath: 'assets/exercise_images/Shoulder/Dumbbell-Z-Press.gif', muscleGroup: 'Shoulder', fileName: 'Dumbbell-Z-Press.gif'),
      const ExerciseImage(name: 'EZ Bar Underhand Press', imagePath: 'assets/exercise_images/Shoulder/EZ-Bar-Underhand-Press.gif', muscleGroup: 'Shoulder', fileName: 'EZ-Bar-Underhand-Press.gif'),
      const ExerciseImage(name: 'Face Pull', imagePath: 'assets/exercise_images/Shoulder/Face-pull (1).gif', muscleGroup: 'Shoulder', fileName: 'Face-pull (1).gif'),
      const ExerciseImage(name: 'Foam Roller Posterior Shoulder', imagePath: 'assets/exercise_images/Shoulder/Foam-Roller-Posterior-Shoulder.gif', muscleGroup: 'Shoulder', fileName: 'Foam-Roller-Posterior-Shoulder.gif'),
      const ExerciseImage(name: 'Full Range Of Motion Lat Pulldown', imagePath: 'assets/exercise_images/Shoulder/Full-Range-Of-Motion-Lat-Pulldown.gif', muscleGroup: 'Shoulder', fileName: 'Full-Range-Of-Motion-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Half Arnold Press', imagePath: 'assets/exercise_images/Shoulder/Half-Arnold-Press.gif', muscleGroup: 'Shoulder', fileName: 'Half-Arnold-Press.gif'),
      const ExerciseImage(name: 'Half Kneeling Cable External Rotation', imagePath: 'assets/exercise_images/Shoulder/Half-Kneeling-Cable-External-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Half-Kneeling-Cable-External-Rotation.gif'),
      const ExerciseImage(name: 'Half Kneeling One Arm Kettlebell Press', imagePath: 'assets/exercise_images/Shoulder/Half-Kneeling-One-Arm-Kettlebell-Press.gif', muscleGroup: 'Shoulder', fileName: 'Half-Kneeling-One-Arm-Kettlebell-Press.gif'),
      const ExerciseImage(name: 'Incline Dumbbell Side Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Incline-Dumbbell-Side-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Incline-Dumbbell-Side-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Incline Front Raise', imagePath: 'assets/exercise_images/Shoulder/Incline-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Incline-Front-Raise.gif'),
      const ExerciseImage(name: 'Incline Landmine Press', imagePath: 'assets/exercise_images/Shoulder/Incline-Landmine-Press.gif', muscleGroup: 'Shoulder', fileName: 'Incline-Landmine-Press.gif'),
      const ExerciseImage(name: 'Kettlebell Arnold Press', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Arnold-Press.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Arnold-Press.gif'),
      const ExerciseImage(name: 'Kettlebell Clean And Jerk', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Clean-and-Jerk.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Clean-and-Jerk.gif'),
      const ExerciseImage(name: 'Kettlebell Clean And Press', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Clean-and-Press.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Clean-and-Press.gif'),
      const ExerciseImage(name: 'Kettlebell Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Kettlebell One Arm Military Press', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-One-Arm-Military-Press.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-One-Arm-Military-Press.gif'),
      const ExerciseImage(name: 'Kettlebell Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Kettlebell Split Snatch', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Split-Snatch.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Split-Snatch.gif'),
      const ExerciseImage(name: 'Kettlebell Thruster', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Thruster.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Thruster.gif'),
      const ExerciseImage(name: 'Kettlebell Windmill', imagePath: 'assets/exercise_images/Shoulder/Kettlebell-Windmill.gif', muscleGroup: 'Shoulder', fileName: 'Kettlebell-Windmill.gif'),
      const ExerciseImage(name: 'Kneeling Back Rotation Stretch', imagePath: 'assets/exercise_images/Shoulder/Kneeling-Back-Rotation-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Kneeling-Back-Rotation-Stretch.gif'),
      const ExerciseImage(name: 'Kneeling Cable Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Kneeling-Cable-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Kneeling-Cable-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Kneeling Landmine Press', imagePath: 'assets/exercise_images/Shoulder/Kneeling-Landmine-Press.gif', muscleGroup: 'Shoulder', fileName: 'Kneeling-Landmine-Press.gif'),
      const ExerciseImage(name: 'Kneeling T Spine Rotation', imagePath: 'assets/exercise_images/Shoulder/Kneeling-T-spine-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Kneeling-T-spine-Rotation.gif'),
      const ExerciseImage(name: 'Landmine Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Landmine-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Landmine-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Landmine Press', imagePath: 'assets/exercise_images/Shoulder/Landmine-Press.gif', muscleGroup: 'Shoulder', fileName: 'Landmine-Press.gif'),
      const ExerciseImage(name: 'Lateral Raise Machine', imagePath: 'assets/exercise_images/Shoulder/Lateral-Raise-Machine.gif', muscleGroup: 'Shoulder', fileName: 'Lateral-Raise-Machine.gif'),
      const ExerciseImage(name: 'Lateral Raise With Towel On Wall', imagePath: 'assets/exercise_images/Shoulder/Lateral-Raise-with-Towel-on-Wall.gif', muscleGroup: 'Shoulder', fileName: 'Lateral-Raise-with-Towel-on-Wall.gif'),
      const ExerciseImage(name: 'Leaning Cable Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Leaning-Cable-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Leaning-Cable-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Leaning Single Arm Dumbbell Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Leaning-Single-Arm-Dumbbell-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Leaning-Single-Arm-Dumbbell-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Lever High Row', imagePath: 'assets/exercise_images/Shoulder/Lever-High-Row.gif', muscleGroup: 'Shoulder', fileName: 'Lever-High-Row.gif'),
      const ExerciseImage(name: 'Lever Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Lever-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Lever-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Lever Reverse Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Lever-Reverse-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Lever-Reverse-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Lever Shoulder Press Hammer Grip', imagePath: 'assets/exercise_images/Shoulder/Lever-Shoulder-Press-Hammer-Grip.gif', muscleGroup: 'Shoulder', fileName: 'Lever-Shoulder-Press-Hammer-Grip.gif'),
      const ExerciseImage(name: 'Lever Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Lever-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Lever-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Lying Cable Reverse Fly', imagePath: 'assets/exercise_images/Shoulder/Lying-Cable-Reverse-Fly.gif', muscleGroup: 'Shoulder', fileName: 'Lying-Cable-Reverse-Fly.gif'),
      const ExerciseImage(name: 'Lying Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Lying-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Lying-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Lying Upper Body Rotation', imagePath: 'assets/exercise_images/Shoulder/Lying-Upper-Body-Rotation.gif', muscleGroup: 'Shoulder', fileName: 'Lying-Upper-Body-Rotation.gif'),
      const ExerciseImage(name: 'Medicine Ball Overhead Slam Exercise', imagePath: 'assets/exercise_images/Shoulder/Medicine-ball-Overhead-Slam-exercise.gif', muscleGroup: 'Shoulder', fileName: 'Medicine-ball-Overhead-Slam-exercise.gif'),
      const ExerciseImage(name: 'One Arm Bent Over Cable Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/One-Arm-Bent-Over-Cable-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'One-Arm-Bent-Over-Cable-Lateral-Raise.gif'),
      const ExerciseImage(name: 'One Arm Dumbbell Snatch', imagePath: 'assets/exercise_images/Shoulder/One-Arm-Dumbbell-Snatch.gif', muscleGroup: 'Shoulder', fileName: 'One-Arm-Dumbbell-Snatch.gif'),
      const ExerciseImage(name: 'One Arm Kettlebell Snatch Exercise', imagePath: 'assets/exercise_images/Shoulder/One-Arm-Kettlebell-Snatch-exercise.gif', muscleGroup: 'Shoulder', fileName: 'One-Arm-Kettlebell-Snatch-exercise.gif'),
      const ExerciseImage(name: 'One Arm Kettlebell Swing', imagePath: 'assets/exercise_images/Shoulder/One-Arm-Kettlebell-Swing.gif', muscleGroup: 'Shoulder', fileName: 'One-Arm-Kettlebell-Swing.gif'),
      const ExerciseImage(name: 'One Arm Landmine Row', imagePath: 'assets/exercise_images/Shoulder/One-Arm-Landmine-Row.gif', muscleGroup: 'Shoulder', fileName: 'One-Arm-Landmine-Row.gif'),
      const ExerciseImage(name: 'One Arm Medicine Ball Slam', imagePath: 'assets/exercise_images/Shoulder/One-Arm-Medicine-Ball-Slam.gif', muscleGroup: 'Shoulder', fileName: 'One-Arm-Medicine-Ball-Slam.gif'),
      const ExerciseImage(name: 'PVC Front Rack Stretch', imagePath: 'assets/exercise_images/Shoulder/PVC-Front-Rack-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'PVC-Front-Rack-Stretch.gif'),
      const ExerciseImage(name: 'Pike Push Up Between Chairs', imagePath: 'assets/exercise_images/Shoulder/Pike-Push-Up-Between-Chairs.gif', muscleGroup: 'Shoulder', fileName: 'Pike-Push-Up-Between-Chairs.gif'),
      const ExerciseImage(name: 'Pike Push Up', imagePath: 'assets/exercise_images/Shoulder/Pike-Push-up.gif', muscleGroup: 'Shoulder', fileName: 'Pike-Push-up.gif'),
      const ExerciseImage(name: 'Pike To Cobra', imagePath: 'assets/exercise_images/Shoulder/Pike-to-Cobra.gif', muscleGroup: 'Shoulder', fileName: 'Pike-to-Cobra.gif'),
      const ExerciseImage(name: 'Plate Loaded Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Plate-Loaded-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Plate-Loaded-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Resistance Band Seated Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Resistance-Band-Seated-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Resistance-Band-Seated-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Reverse Shoulder Stretch', imagePath: 'assets/exercise_images/Shoulder/Reverse-Shoulder-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Reverse-Shoulder-Stretch.gif'),
      const ExerciseImage(name: 'Roll Front Shoulder And Chest Lying On Floor', imagePath: 'assets/exercise_images/Shoulder/Roll-Front-Shoulder-and-Chest-Lying-on-Floor.gif', muscleGroup: 'Shoulder', fileName: 'Roll-Front-Shoulder-and-Chest-Lying-on-Floor.gif'),
      const ExerciseImage(name: 'Rotator Cuff Stretch', imagePath: 'assets/exercise_images/Shoulder/Rotator-Cuff-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Rotator-Cuff-Stretch.gif'),
      const ExerciseImage(name: 'Seated Behind The Neck Press', imagePath: 'assets/exercise_images/Shoulder/Seated-Behind-the-Neck-Press.gif', muscleGroup: 'Shoulder', fileName: 'Seated-Behind-the-Neck-Press.gif'),
      const ExerciseImage(name: 'Seated Dumbbell Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Seated-Dumbbell-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Seated-Dumbbell-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Seated Rear Lateral Dumbbell Raise', imagePath: 'assets/exercise_images/Shoulder/Seated-Rear-Lateral-Dumbbell-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Seated-Rear-Lateral-Dumbbell-Raise.gif'),
      const ExerciseImage(name: 'Side Bend Press', imagePath: 'assets/exercise_images/Shoulder/Side-Bend-Press.gif', muscleGroup: 'Shoulder', fileName: 'Side-Bend-Press.gif'),
      const ExerciseImage(name: 'Side Lying Rear Delt Dumbbell Raise', imagePath: 'assets/exercise_images/Shoulder/Side-Lying-Rear-Delt-Dumbbell-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Side-Lying-Rear-Delt-Dumbbell-Raise.gif'),
      const ExerciseImage(name: 'Single Arm Arnold Press', imagePath: 'assets/exercise_images/Shoulder/Single-Arm-Arnold-Press.gif', muscleGroup: 'Shoulder', fileName: 'Single-Arm-Arnold-Press.gif'),
      const ExerciseImage(name: 'Skier Gymstick', imagePath: 'assets/exercise_images/Shoulder/Skier-Gymstick.gif', muscleGroup: 'Shoulder', fileName: 'Skier-Gymstick.gif'),
      const ExerciseImage(name: 'Smith Machine Behind Neck Press', imagePath: 'assets/exercise_images/Shoulder/Smith-Machine-Behind-Neck-Press.gif', muscleGroup: 'Shoulder', fileName: 'Smith-Machine-Behind-Neck-Press.gif'),
      const ExerciseImage(name: 'Smith Machine Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Smith-Machine-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Smith-Machine-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Standing Alternating Dumbbell Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Standing-Alternating-Dumbbell-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Standing-Alternating-Dumbbell-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Standing Barbell Close Grip Military Press', imagePath: 'assets/exercise_images/Shoulder/Standing-Barbell-Close-Grip-Military-Press.gif', muscleGroup: 'Shoulder', fileName: 'Standing-Barbell-Close-Grip-Military-Press.gif'),
      const ExerciseImage(name: 'Standing Behind Head Military Press', imagePath: 'assets/exercise_images/Shoulder/Standing-Behind-Head-Military-Press.gif', muscleGroup: 'Shoulder', fileName: 'Standing-Behind-Head-Military-Press.gif'),
      const ExerciseImage(name: 'Standing Dumbbell Overhead Press', imagePath: 'assets/exercise_images/Shoulder/Standing-Dumbbell-Overhead-Press.gif', muscleGroup: 'Shoulder', fileName: 'Standing-Dumbbell-Overhead-Press.gif'),
      const ExerciseImage(name: 'Standing Reach Up Back Rotation Stretch', imagePath: 'assets/exercise_images/Shoulder/Standing-Reach-Up-Back-rotation-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Standing-Reach-Up-Back-rotation-Stretch.gif'),
      const ExerciseImage(name: 'Standing Reverse Shoulder Stretch', imagePath: 'assets/exercise_images/Shoulder/Standing-Reverse-Shoulder-Stretch.gif', muscleGroup: 'Shoulder', fileName: 'Standing-Reverse-Shoulder-Stretch.gif'),
      const ExerciseImage(name: 'Standing Smith Machine Shoulder Press', imagePath: 'assets/exercise_images/Shoulder/Standing-Smith-Machine-Shoulder-Press.gif', muscleGroup: 'Shoulder', fileName: 'Standing-Smith-Machine-Shoulder-Press.gif'),
      const ExerciseImage(name: 'Swing Gymstick', imagePath: 'assets/exercise_images/Shoulder/Swing-Gymstick.gif', muscleGroup: 'Shoulder', fileName: 'Swing-Gymstick.gif'),
      const ExerciseImage(name: 'Two Arm Cable Front Raise', imagePath: 'assets/exercise_images/Shoulder/Two-Arm-Cable-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Two-Arm-Cable-Front-Raise.gif'),
      const ExerciseImage(name: 'Two Arm Cable Lateral Raise', imagePath: 'assets/exercise_images/Shoulder/Two-Arm-Cable-Lateral-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Two-Arm-Cable-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Two Arm Dumbbell Front Raise', imagePath: 'assets/exercise_images/Shoulder/Two-Arm-Dumbbell-Front-Raise.gif', muscleGroup: 'Shoulder', fileName: 'Two-Arm-Dumbbell-Front-Raise.gif'),
      const ExerciseImage(name: 'Wall Supported Arm Raises', imagePath: 'assets/exercise_images/Shoulder/Wall-Supported-Arm-Raises.gif', muscleGroup: 'Shoulder', fileName: 'Wall-Supported-Arm-Raises.gif'),
      const ExerciseImage(name: 'Weight Plate Front Raise', imagePath: 'assets/exercise_images/Shoulder/Weight-Plate-Front-Raise-1.gif', muscleGroup: 'Shoulder', fileName: 'Weight-Plate-Front-Raise-1.gif'),
      const ExerciseImage(name: 'Arm Circles', imagePath: 'assets/exercise_images/Shoulder/arm-circles.gif', muscleGroup: 'Shoulder', fileName: 'arm-circles.gif'),
      const ExerciseImage(name: 'Dumbbell Cuban Press', imagePath: 'assets/exercise_images/Shoulder/dumbbell-cuban-press-.gif', muscleGroup: 'Shoulder', fileName: 'dumbbell-cuban-press-.gif'),
      const ExerciseImage(name: 'Handstand Push Up', imagePath: 'assets/exercise_images/Shoulder/handstand-push-up.gif', muscleGroup: 'Shoulder', fileName: 'handstand-push-up.gif'),
      const ExerciseImage(name: 'Pendulum', imagePath: 'assets/exercise_images/Shoulder/pendulum.gif', muscleGroup: 'Shoulder', fileName: 'pendulum.gif'),
      const ExerciseImage(name: 'Push Press', imagePath: 'assets/exercise_images/Shoulder/push-press-1.gif', muscleGroup: 'Shoulder', fileName: 'push-press-1.gif'),
      const ExerciseImage(name: 'Scott Press', imagePath: 'assets/exercise_images/Shoulder/scott-press.gif', muscleGroup: 'Shoulder', fileName: 'scott-press.gif'),
      const ExerciseImage(name: 'Seated Dumbbell Front Raise', imagePath: 'assets/exercise_images/Shoulder/seated-dumbbell-front-raise.gif', muscleGroup: 'Shoulder', fileName: 'seated-dumbbell-front-raise.gif'),
      const ExerciseImage(name: 'Shoulder External Rotation Stretch', imagePath: 'assets/exercise_images/Shoulder/shoulder-external-rotation-stretch.gif', muscleGroup: 'Shoulder', fileName: 'shoulder-external-rotation-stretch.gif'),
      const ExerciseImage(name: 'Shoulder Internal Rotation Stretch', imagePath: 'assets/exercise_images/Shoulder/shoulder-internal-rotation-stretch.gif', muscleGroup: 'Shoulder', fileName: 'shoulder-internal-rotation-stretch.gif'),
      const ExerciseImage(name: 'Thruster', imagePath: 'assets/exercise_images/Shoulder/thruster.gif', muscleGroup: 'Shoulder', fileName: 'thruster.gif'),
      const ExerciseImage(name: 'Wall Ball', imagePath: 'assets/exercise_images/Shoulder/wall-ball.gif', muscleGroup: 'Shoulder', fileName: 'wall-ball.gif'),
      const ExerciseImage(name: 'Wall Slide', imagePath: 'assets/exercise_images/Shoulder/wall-slide.gif', muscleGroup: 'Shoulder', fileName: 'wall-slide.gif'),
      const ExerciseImage(name: 'Weighted Round Arm', imagePath: 'assets/exercise_images/Shoulder/weighted-round-arm.gif', muscleGroup: 'Shoulder', fileName: 'weighted-round-arm.gif'),
    ];
  }

  // Abs/Core exercises - all actual exercises from the folder
  static List<ExerciseImage> _getAbsCoreExercises() {
    return [
      const ExerciseImage(name: '4 Point Tummy Vacuum Exercise', imagePath: 'assets/exercise_images/Abs or core/4-Point-Tummy-Vacuum-Exercise.gif', muscleGroup: 'Abs or Core', fileName: '4-Point-Tummy-Vacuum-Exercise.gif'),
      const ExerciseImage(name: 'Ab Coaster Machine', imagePath: 'assets/exercise_images/Abs or core/Ab-Coaster-Machine.gif', muscleGroup: 'Abs or Core', fileName: 'Ab-Coaster-Machine.gif'),
      const ExerciseImage(name: 'Ab Roller Crunch', imagePath: 'assets/exercise_images/Abs or core/Ab-Roller-Crunch.gif', muscleGroup: 'Abs or Core', fileName: 'Ab-Roller-Crunch.gif'),
      const ExerciseImage(name: 'Ab Straps Leg Raise', imagePath: 'assets/exercise_images/Abs or core/Ab-Straps-Leg-Raise.gif', muscleGroup: 'Abs or Core', fileName: 'Ab-Straps-Leg-Raise.gif'),
      const ExerciseImage(name: 'Alternate Leg Raises', imagePath: 'assets/exercise_images/Abs or core/Alternate-Leg-Raises.gif', muscleGroup: 'Abs or Core', fileName: 'Alternate-Leg-Raises.gif'),
      const ExerciseImage(name: 'Alternate Lying Floor Leg Raise', imagePath: 'assets/exercise_images/Abs or core/Alternate-Lying-Floor-Leg-Raise.gif', muscleGroup: 'Abs or Core', fileName: 'Alternate-Lying-Floor-Leg-Raise.gif'),
      const ExerciseImage(name: 'Ball Russian Twist Throw With Partner', imagePath: 'assets/exercise_images/Abs or core/Ball-Russian-Twist-throw-with-partner.gif', muscleGroup: 'Abs or Core', fileName: 'Ball-Russian-Twist-throw-with-partner.gif'),
      const ExerciseImage(name: 'Barbell Rollout', imagePath: 'assets/exercise_images/Abs or core/Barbell-Rollout.gif', muscleGroup: 'Abs or Core', fileName: 'Barbell-Rollout.gif'),
      const ExerciseImage(name: 'Barbell Seated Twist', imagePath: 'assets/exercise_images/Abs or core/Barbell-Seated-Twist.gif', muscleGroup: 'Abs or Core', fileName: 'Barbell-Seated-Twist.gif'),
      const ExerciseImage(name: 'Barbell Side Bend', imagePath: 'assets/exercise_images/Abs or core/Barbell-Side-Bend.gif', muscleGroup: 'Abs or Core', fileName: 'Barbell-Side-Bend.gif'),
      const ExerciseImage(name: 'Bench Side Bend', imagePath: 'assets/exercise_images/Abs or core/Bench-Side-Bend.gif', muscleGroup: 'Abs or Core', fileName: 'Bench-Side-Bend.gif'),
      const ExerciseImage(name: 'Bent Over Twist', imagePath: 'assets/exercise_images/Abs or core/Bent-Over-Twist.gif', muscleGroup: 'Abs or Core', fileName: 'Bent-Over-Twist.gif'),
      const ExerciseImage(name: 'Bicycle Crunch Gymstick', imagePath: 'assets/exercise_images/Abs or core/Bicycle-Crunch-Gymstick.gif', muscleGroup: 'Abs or Core', fileName: 'Bicycle-Crunch-Gymstick.gif'),
      const ExerciseImage(name: 'Bicycle Crunch', imagePath: 'assets/exercise_images/Abs or core/Bicycle-Crunch.gif', muscleGroup: 'Abs or Core', fileName: 'Bicycle-Crunch.gif'),
      const ExerciseImage(name: 'Bicycle Twisting Crunch', imagePath: 'assets/exercise_images/Abs or core/Bicycle-Twisting-Crunch.gif', muscleGroup: 'Abs or Core', fileName: 'Bicycle-Twisting-Crunch.gif'),
      const ExerciseImage(name: 'Boat Pose Stretch', imagePath: 'assets/exercise_images/Abs or core/Boat-Pose-Stretch.gif', muscleGroup: 'Abs or Core', fileName: 'Boat-Pose-Stretch.gif'),
      const ExerciseImage(name: 'Bodyweight Windmill', imagePath: 'assets/exercise_images/Abs or core/Bodyweight-Windmill.gif', muscleGroup: 'Abs or Core', fileName: 'Bodyweight-Windmill.gif'),
      const ExerciseImage(name: 'Butterfly Sit Up', imagePath: 'assets/exercise_images/Abs or core/Butterfly-Sit-up.gif', muscleGroup: 'Abs or Core', fileName: 'Butterfly-Sit-up.gif'),
      const ExerciseImage(name: 'Cable Seated Cross Arm Twist', imagePath: 'assets/exercise_images/Abs or core/Cable-Seated-Cross-Arm-Twist.gif', muscleGroup: 'Abs or Core', fileName: 'Cable-Seated-Cross-Arm-Twist.gif'),
      const ExerciseImage(name: 'Cable Seated Twist On Floor', imagePath: 'assets/exercise_images/Abs or core/Cable-Seated-Twist-on-Floor.gif', muscleGroup: 'Abs or Core', fileName: 'Cable-Seated-Twist-on-Floor.gif'),
      const ExerciseImage(name: 'Cable Side Bend', imagePath: 'assets/exercise_images/Abs or core/Cable-Side-Bend.gif', muscleGroup: 'Abs or Core', fileName: 'Cable-Side-Bend.gif'),
      const ExerciseImage(name: 'Captains Chair Leg Raise', imagePath: 'assets/exercise_images/Abs or core/Captains-Chair-Leg-Raise.gif', muscleGroup: 'Abs or Core', fileName: 'Captains-Chair-Leg-Raise.gif'),
      const ExerciseImage(name: 'Crab Twist Toe Touch', imagePath: 'assets/exercise_images/Abs or core/Crab-Twist-Toe-Touch.gif', muscleGroup: 'Abs or Core', fileName: 'Crab-Twist-Toe-Touch.gif'),
      const ExerciseImage(name: 'Cross Body Mountain Climber', imagePath: 'assets/exercise_images/Abs or core/Cross-Body-Mountain-Climber.gif', muscleGroup: 'Abs or Core', fileName: 'Cross-Body-Mountain-Climber.gif'),
      const ExerciseImage(name: 'Cross Crunch', imagePath: 'assets/exercise_images/Abs or core/Cross-Crunch.gif', muscleGroup: 'Abs or Core', fileName: 'Cross-Crunch.gif'),
      const ExerciseImage(name: 'Crunch With Leg Raise', imagePath: 'assets/exercise_images/Abs or core/Crunch-With-Leg-Raise.gif', muscleGroup: 'Abs or Core', fileName: 'Crunch-With-Leg-Raise.gif'),
      const ExerciseImage(name: 'Crunch', imagePath: 'assets/exercise_images/Abs or core/Crunch.gif', muscleGroup: 'Abs or Core', fileName: 'Crunch.gif'),
    ];
  }

  // Back & Wings exercises - placeholder
  // Back & Wings exercises - ALL actual exercises from the folder (59 exercises)
  static List<ExerciseImage> _getBackWingsExercises() {
    return [
      const ExerciseImage(name: 'Assisted Pull Up', imagePath: 'assets/exercise_images/back or wing/Assisted-Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Assisted-Pull-up.gif'),
      const ExerciseImage(name: 'Band Alternating Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/Band-Alternating-Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Band-Alternating-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Band Alternating Low Row With Twist', imagePath: 'assets/exercise_images/back or wing/Band-Alternating-Low-Row-with-Twist.gif', muscleGroup: 'Back & Wings', fileName: 'Band-Alternating-Low-Row-with-Twist.gif'),
      const ExerciseImage(name: 'Barbell Decline Bent Arm Pullover', imagePath: 'assets/exercise_images/back or wing/Barbell-Decline-Bent-Arm-Pullover.gif', muscleGroup: 'Back & Wings', fileName: 'Barbell-Decline-Bent-Arm-Pullover.gif'),
      const ExerciseImage(name: 'Behind The Neck Pull Up', imagePath: 'assets/exercise_images/back or wing/Behind-The-Neck-Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Behind-The-Neck-Pull-up.gif'),
      const ExerciseImage(name: 'Bodyweight Row In Doorway', imagePath: 'assets/exercise_images/back or wing/Bodyweight-Row-in-Doorway.gif', muscleGroup: 'Back & Wings', fileName: 'Bodyweight-Row-in-Doorway.gif'),
      const ExerciseImage(name: 'Cable Bent Over Row', imagePath: 'assets/exercise_images/back or wing/Cable-Bent-Over-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-Bent-Over-Row.gif'),
      const ExerciseImage(name: 'Cable Crossover Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/Cable-Crossover-Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-Crossover-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Cable One Arm Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/Cable-One-Arm-Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-One-Arm-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Cable One Arm Pulldown', imagePath: 'assets/exercise_images/back or wing/Cable-One-Arm-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-One-Arm-Pulldown.gif'),
      const ExerciseImage(name: 'Cable Rear Pulldown', imagePath: 'assets/exercise_images/back or wing/Cable-Rear-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-Rear-Pulldown.gif'),
      const ExerciseImage(name: 'Cable Seated Pullover', imagePath: 'assets/exercise_images/back or wing/Cable-Seated-Pullover.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-Seated-Pullover.gif'),
      const ExerciseImage(name: 'Cable Straight Arm Pulldown', imagePath: 'assets/exercise_images/back or wing/Cable-Straight-Arm-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-Straight-Arm-Pulldown.gif'),
      const ExerciseImage(name: 'Cable Twisting Standing High Row', imagePath: 'assets/exercise_images/back or wing/Cable-Twisting-Standing-high-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Cable-Twisting-Standing-high-Row.gif'),
      const ExerciseImage(name: 'Close Grip Chin Up', imagePath: 'assets/exercise_images/back or wing/Close-Grip-Chin-Up.gif', muscleGroup: 'Back & Wings', fileName: 'Close-Grip-Chin-Up.gif'),
      const ExerciseImage(name: 'Close Grip Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/Close-Grip-Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Close-Grip-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Double Cable Neutral Grip Lat Pulldown On Floor', imagePath: 'assets/exercise_images/back or wing/Double-Cable-Neutral-Grip-Lat-Pulldown-On-Floor.gif', muscleGroup: 'Back & Wings', fileName: 'Double-Cable-Neutral-Grip-Lat-Pulldown-On-Floor.gif'),
      const ExerciseImage(name: 'Dumbbell Bent Over Reverse Row', imagePath: 'assets/exercise_images/back or wing/Dumbbell-Bent-Over-Reverse-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Dumbbell-Bent-Over-Reverse-Row.gif'),
      const ExerciseImage(name: 'Dumbbell Row', imagePath: 'assets/exercise_images/back or wing/Dumbbell-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Dumbbell-Row.gif'),
      const ExerciseImage(name: 'Dumbbell Seal Row', imagePath: 'assets/exercise_images/back or wing/Dumbbell-Seal-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Dumbbell-Seal-Row.gif'),
      const ExerciseImage(name: 'Foam Roller Lat Stretch', imagePath: 'assets/exercise_images/back or wing/Foam-Roller-Lat-Stretch.gif', muscleGroup: 'Back & Wings', fileName: 'Foam-Roller-Lat-Stretch.gif'),
      const ExerciseImage(name: 'Front Pulldown', imagePath: 'assets/exercise_images/back or wing/Front-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Front-Pulldown.gif'),
      const ExerciseImage(name: 'Half Kneeling Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/Half-Kneeling-Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Half-Kneeling-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'How To Do Band Assisted Muscle Up', imagePath: 'assets/exercise_images/back or wing/How-to-do-Band-Assisted-Muscle-Up.gif', muscleGroup: 'Back & Wings', fileName: 'How-to-do-Band-Assisted-Muscle-Up.gif'),
      const ExerciseImage(name: 'Incline Barbell Row', imagePath: 'assets/exercise_images/back or wing/Incline-Barbell-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Incline-Barbell-Row.gif'),
      const ExerciseImage(name: 'Incline Cable Row', imagePath: 'assets/exercise_images/back or wing/Incline-Cable-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Incline-Cable-Row.gif'),
      const ExerciseImage(name: 'Incline Dumbbell Hammer Row', imagePath: 'assets/exercise_images/back or wing/Incline-Dumbbell-Hammer-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Incline-Dumbbell-Hammer-Row.gif'),
      const ExerciseImage(name: 'Incline Reverse Grip Dumbbell Row', imagePath: 'assets/exercise_images/back or wing/Incline-Reverse-Grip-Dumbbell-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Incline-Reverse-Grip-Dumbbell-Row.gif'),
      const ExerciseImage(name: 'Inverted Row', imagePath: 'assets/exercise_images/back or wing/Inverted-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Inverted-Row.gif'),
      const ExerciseImage(name: 'Isometric Pull Up', imagePath: 'assets/exercise_images/back or wing/Isometric-Pull-Up.gif', muscleGroup: 'Back & Wings', fileName: 'Isometric-Pull-Up.gif'),
      const ExerciseImage(name: 'Kettlebell Bent Over Row', imagePath: 'assets/exercise_images/back or wing/Kettlebell-Bent-Over-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Kettlebell-Bent-Over-Row.gif'),
      const ExerciseImage(name: 'Kneeling Single Arm High Pulley Row', imagePath: 'assets/exercise_images/back or wing/Kneeling-Single-Arm-High-Pulley-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Kneeling-Single-Arm-High-Pulley-Row.gif'),
      const ExerciseImage(name: 'Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Lever Cable Rear Pulldown', imagePath: 'assets/exercise_images/back or wing/Lever-Cable-Rear-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Lever-Cable-Rear-Pulldown.gif'),
      const ExerciseImage(name: 'Lever Pullover Plate Loaded', imagePath: 'assets/exercise_images/back or wing/Lever-Pullover-plate-loaded.gif', muscleGroup: 'Back & Wings', fileName: 'Lever-Pullover-plate-loaded.gif'),
      const ExerciseImage(name: 'Lever Reverse T Bar Row', imagePath: 'assets/exercise_images/back or wing/Lever-Reverse-T-Bar-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Lever-Reverse-T-Bar-Row.gif'),
      const ExerciseImage(name: 'Lever T Bar Row', imagePath: 'assets/exercise_images/back or wing/Lever-T-bar-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Lever-T-bar-Row.gif'),
      const ExerciseImage(name: 'One Arm Barbell Row', imagePath: 'assets/exercise_images/back or wing/One-Arm-Barbell-Row-.gif', muscleGroup: 'Back & Wings', fileName: 'One-Arm-Barbell-Row-.gif'),
      const ExerciseImage(name: 'One Arm Cable Row', imagePath: 'assets/exercise_images/back or wing/One-arm-Cable-Row.gif', muscleGroup: 'Back & Wings', fileName: 'One-arm-Cable-Row.gif'),
      const ExerciseImage(name: 'Plate Loaded Seated Row', imagePath: 'assets/exercise_images/back or wing/Plate-Loaded-Seated-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Plate-Loaded-Seated-Row.gif'),
      const ExerciseImage(name: 'Pull Up', imagePath: 'assets/exercise_images/back or wing/Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Pull-up.gif'),
      const ExerciseImage(name: 'Reverse Grip Barbell Row', imagePath: 'assets/exercise_images/back or wing/Reverse-Grip-Barbell-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Reverse-Grip-Barbell-Row.gif'),
      const ExerciseImage(name: 'Reverse Grip Machine Row', imagePath: 'assets/exercise_images/back or wing/Reverse-Grip-Machine-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Reverse-Grip-Machine-Row.gif'),
      const ExerciseImage(name: 'Reverse Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/Reverse-Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Reverse-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Reverse Grip Pull Up', imagePath: 'assets/exercise_images/back or wing/Reverse-grip-Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Reverse-grip-Pull-up.gif'),
      const ExerciseImage(name: 'Ring Inverted Row', imagePath: 'assets/exercise_images/back or wing/Ring-Inverted-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Ring-Inverted-Row.gif'),
      const ExerciseImage(name: 'Rope Straight Arm Pulldown', imagePath: 'assets/exercise_images/back or wing/Rope-Straight-Arm-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'Rope-Straight-Arm-Pulldown.gif'),
      const ExerciseImage(name: 'Seated Cable Row', imagePath: 'assets/exercise_images/back or wing/Seated-Cable-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Seated-Cable-Row.gif'),
      const ExerciseImage(name: 'Seated Row Machine', imagePath: 'assets/exercise_images/back or wing/Seated-Row-Machine.gif', muscleGroup: 'Back & Wings', fileName: 'Seated-Row-Machine.gif'),
      const ExerciseImage(name: 'Single Arm Twisting Seated Cable Row', imagePath: 'assets/exercise_images/back or wing/Single-Arm-Twisting-Seated-Cable-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Single-Arm-Twisting-Seated-Cable-Row.gif'),
      const ExerciseImage(name: 'Smith Machine Bent Over Row', imagePath: 'assets/exercise_images/back or wing/Smith-Machine-Bent-Over-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Smith-Machine-Bent-Over-Row.gif'),
      const ExerciseImage(name: 'Standing Side Bend Stretch', imagePath: 'assets/exercise_images/back or wing/Standing-Side-Bend-Stretch.gif', muscleGroup: 'Back & Wings', fileName: 'Standing-Side-Bend-Stretch.gif'),
      const ExerciseImage(name: 'Straight Back Back Standing Row', imagePath: 'assets/exercise_images/back or wing/Straight_Back-back-standing-row.gif', muscleGroup: 'Back & Wings', fileName: 'Straight_Back-back-standing-row.gif'),
      const ExerciseImage(name: 'Swing 360', imagePath: 'assets/exercise_images/back or wing/Swing-360.gif', muscleGroup: 'Back & Wings', fileName: 'Swing-360.gif'),
      const ExerciseImage(name: 'Table Inverted Row', imagePath: 'assets/exercise_images/back or wing/Table-Inverted-Row.gif', muscleGroup: 'Back & Wings', fileName: 'Table-Inverted-Row.gif'),
      const ExerciseImage(name: 'Top Half Pull Up', imagePath: 'assets/exercise_images/back or wing/Top-Half-Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Top-Half-Pull-up.gif'),
      const ExerciseImage(name: 'Upper Back Stretch', imagePath: 'assets/exercise_images/back or wing/Upper-Back-Stretch.gif', muscleGroup: 'Back & Wings', fileName: 'Upper-Back-Stretch.gif'),
      const ExerciseImage(name: 'Upside Down Pull Up', imagePath: 'assets/exercise_images/back or wing/Upside-Down-Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Upside-Down-Pull-up.gif'),
      const ExerciseImage(name: 'V Bar Lat Pulldown', imagePath: 'assets/exercise_images/back or wing/V-bar-Lat-Pulldown.gif', muscleGroup: 'Back & Wings', fileName: 'V-bar-Lat-Pulldown.gif'),
      const ExerciseImage(name: 'Weighted Muscle Up', imagePath: 'assets/exercise_images/back or wing/Weighted-Muscle-Up.gif', muscleGroup: 'Back & Wings', fileName: 'Weighted-Muscle-Up.gif'),
      const ExerciseImage(name: 'Weighted One Arm Pull Up', imagePath: 'assets/exercise_images/back or wing/Weighted-One-Arm-Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Weighted-One-Arm-Pull-up.gif'),
      const ExerciseImage(name: 'Weighted Pull Up', imagePath: 'assets/exercise_images/back or wing/Weighted-Pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'Weighted-Pull-up.gif'),
      const ExerciseImage(name: 'Band Assisted Pull Up', imagePath: 'assets/exercise_images/back or wing/band-assisted-pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'band-assisted-pull-up.gif'),
      const ExerciseImage(name: 'Close Grip Cable Row', imagePath: 'assets/exercise_images/back or wing/close-grip-cable-row.gif', muscleGroup: 'Back & Wings', fileName: 'close-grip-cable-row.gif'),
      const ExerciseImage(name: 'Commander Pull Up', imagePath: 'assets/exercise_images/back or wing/commander-pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'commander-pull-up.gif'),
      const ExerciseImage(name: 'Dead Hang', imagePath: 'assets/exercise_images/back or wing/dead-hang-360x360.png', muscleGroup: 'Back & Wings', fileName: 'dead-hang-360x360.png'),
      const ExerciseImage(name: 'Eccentric Pull Up Female', imagePath: 'assets/exercise_images/back or wing/eccentric-pull-up-female.gif', muscleGroup: 'Back & Wings', fileName: 'eccentric-pull-up-female.gif'),
      const ExerciseImage(name: 'Neutral Grip Pull Up', imagePath: 'assets/exercise_images/back or wing/neutral-grip-pull-up.gif', muscleGroup: 'Back & Wings', fileName: 'neutral-grip-pull-up.gif'),
      const ExerciseImage(name: 'Shotgun Row', imagePath: 'assets/exercise_images/back or wing/shotgun-row.gif', muscleGroup: 'Back & Wings', fileName: 'shotgun-row.gif'),
      const ExerciseImage(name: 'Standing Side Bend', imagePath: 'assets/exercise_images/back or wing/standing-side-bend.gif', muscleGroup: 'Back & Wings', fileName: 'standing-side-bend.gif'),
    ];
  }

  // Biceps exercises - ALL actual exercises from the folder (51 exercises)
  static List<ExerciseImage> _getBicepsExercises() {
    return [
      const ExerciseImage(name: 'Arm Blaster Hammer Curl', imagePath: 'assets/exercise_images/Biceps/Arm-Blaster-Hammer-Curl.gif', muscleGroup: 'Biceps', fileName: 'Arm-Blaster-Hammer-Curl.gif'),
      const ExerciseImage(name: 'Band Biceps Curl', imagePath: 'assets/exercise_images/Biceps/Band-Biceps-Curl.gif', muscleGroup: 'Biceps', fileName: 'Band-Biceps-Curl.gif'),
      const ExerciseImage(name: 'Barbell Alternate Biceps Curl', imagePath: 'assets/exercise_images/Biceps/Barbell-Alternate-Biceps-Curl.gif', muscleGroup: 'Biceps', fileName: 'Barbell-Alternate-Biceps-Curl.gif'),
      const ExerciseImage(name: 'Barbell Curl On Arm Blaster', imagePath: 'assets/exercise_images/Biceps/Barbell-Curl-On-Arm-Blaster.gif', muscleGroup: 'Biceps', fileName: 'Barbell-Curl-On-Arm-Blaster.gif'),
      const ExerciseImage(name: 'Barbell Curl', imagePath: 'assets/exercise_images/Biceps/Barbell-Curl.gif', muscleGroup: 'Biceps', fileName: 'Barbell-Curl.gif'),
      const ExerciseImage(name: 'Barbell Drag Curl', imagePath: 'assets/exercise_images/Biceps/Barbell-Drag-Curl.gif', muscleGroup: 'Biceps', fileName: 'Barbell-Drag-Curl.gif'),
      const ExerciseImage(name: 'Bicep Curl Machine', imagePath: 'assets/exercise_images/Biceps/Bicep-Curl-Machine.gif', muscleGroup: 'Biceps', fileName: 'Bicep-Curl-Machine.gif'),
      const ExerciseImage(name: 'Biceps Leg Concentration Curl', imagePath: 'assets/exercise_images/Biceps/Biceps-Leg-Concentration-Curl.gif', muscleGroup: 'Biceps', fileName: 'Biceps-Leg-Concentration-Curl.gif'),
      const ExerciseImage(name: 'Brachialis Pull Up', imagePath: 'assets/exercise_images/Biceps/Brachialis-Pull-up.gif', muscleGroup: 'Biceps', fileName: 'Brachialis-Pull-up.gif'),
      const ExerciseImage(name: 'Cable Concentration Curl', imagePath: 'assets/exercise_images/Biceps/Cable-Concentration-Curl.gif', muscleGroup: 'Biceps', fileName: 'Cable-Concentration-Curl.gif'),
      const ExerciseImage(name: 'Cable Incline Biceps Curl', imagePath: 'assets/exercise_images/Biceps/Cable-Incline-Biceps-Curl.gif', muscleGroup: 'Biceps', fileName: 'Cable-Incline-Biceps-Curl.gif'),
      const ExerciseImage(name: 'Cable Kneeling Biceps Curl', imagePath: 'assets/exercise_images/Biceps/Cable-Kneeling-Biceps-Curl.gif', muscleGroup: 'Biceps', fileName: 'Cable-Kneeling-Biceps-Curl.gif'),
      const ExerciseImage(name: 'Cable Pulldown Bicep Curl', imagePath: 'assets/exercise_images/Biceps/Cable-Pulldown-Bicep-Curl.gif', muscleGroup: 'Biceps', fileName: 'Cable-Pulldown-Bicep-Curl.gif'),
      const ExerciseImage(name: 'Cable Two Arm Curl On Incline Bench', imagePath: 'assets/exercise_images/Biceps/Cable-Two-Arm-Curl-on-Incline-Bench.gif', muscleGroup: 'Biceps', fileName: 'Cable-Two-Arm-Curl-on-Incline-Bench.gif'),
      const ExerciseImage(name: 'Chin Up Around The Bar', imagePath: 'assets/exercise_images/Biceps/Chin-Up-Around-the-Bar.gif', muscleGroup: 'Biceps', fileName: 'Chin-Up-Around-the-Bar.gif'),
      const ExerciseImage(name: 'Chin Up', imagePath: 'assets/exercise_images/Biceps/Chin-Up.gif', muscleGroup: 'Biceps', fileName: 'Chin-Up.gif'),
      const ExerciseImage(name: 'Close Grip Z Bar Curl', imagePath: 'assets/exercise_images/Biceps/Close-Grip-Z-Bar-Curl.gif', muscleGroup: 'Biceps', fileName: 'Close-Grip-Z-Bar-Curl.gif'),
      const ExerciseImage(name: 'Concentration Curl', imagePath: 'assets/exercise_images/Biceps/Concentration-Curl.gif', muscleGroup: 'Biceps', fileName: 'Concentration-Curl.gif'),
      const ExerciseImage(name: 'Double Arm Dumbbell Curl', imagePath: 'assets/exercise_images/Biceps/Double-Arm-Dumbbell-Curl.gif', muscleGroup: 'Biceps', fileName: 'Double-Arm-Dumbbell-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell Alternate Preacher Curl', imagePath: 'assets/exercise_images/Biceps/Dumbbell-Alternate-Preacher-Curl.gif', muscleGroup: 'Biceps', fileName: 'Dumbbell-Alternate-Preacher-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell Curl On Arm Blaster', imagePath: 'assets/exercise_images/Biceps/Dumbbell-Curl-On-Arm-Blaster.gif', muscleGroup: 'Biceps', fileName: 'Dumbbell-Curl-On-Arm-Blaster.gif'),
      const ExerciseImage(name: 'Dumbbell Curl', imagePath: 'assets/exercise_images/Biceps/Dumbbell-Curl.gif', muscleGroup: 'Biceps', fileName: 'Dumbbell-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell High Curl', imagePath: 'assets/exercise_images/Biceps/Dumbbell-High-Curl.gif', muscleGroup: 'Biceps', fileName: 'Dumbbell-High-Curl.gif'),
      const ExerciseImage(name: 'Dumbbell Preacher Curl', imagePath: 'assets/exercise_images/Biceps/Dumbbell-Preacher-Curl.gif', muscleGroup: 'Biceps', fileName: 'Dumbbell-Preacher-Curl.gif'),
      const ExerciseImage(name: 'Flexor Incline Dumbbell Curls', imagePath: 'assets/exercise_images/Biceps/Flexor-Incline-Dumbbell-Curls.gif', muscleGroup: 'Biceps', fileName: 'Flexor-Incline-Dumbbell-Curls.gif'),
      const ExerciseImage(name: 'Hammer Curl', imagePath: 'assets/exercise_images/Biceps/Hammer-Curl.gif', muscleGroup: 'Biceps', fileName: 'Hammer-Curl.gif'),
      const ExerciseImage(name: 'Lever Biceps Curl', imagePath: 'assets/exercise_images/Biceps/Lever-Biceps-Curl.gif', muscleGroup: 'Biceps', fileName: 'Lever-Biceps-Curl.gif'),
      const ExerciseImage(name: 'Lever Preacher Curl', imagePath: 'assets/exercise_images/Biceps/Lever-Preacher-Curl.gif', muscleGroup: 'Biceps', fileName: 'Lever-Preacher-Curl.gif'),
      const ExerciseImage(name: 'Lying High Bench Barbell Curl', imagePath: 'assets/exercise_images/Biceps/Lying-High-Bench-Barbell-Curl.gif', muscleGroup: 'Biceps', fileName: 'Lying-High-Bench-Barbell-Curl.gif'),
      const ExerciseImage(name: 'One Arm Biceps Curl', imagePath: 'assets/exercise_images/Biceps/One-Arm-Biceps-Curl-1.gif', muscleGroup: 'Biceps', fileName: 'One-Arm-Biceps-Curl-1.gif'),
      const ExerciseImage(name: 'One Arm Biceps Curl', imagePath: 'assets/exercise_images/Biceps/One-Arm-Biceps-Curl.gif', muscleGroup: 'Biceps', fileName: 'One-Arm-Biceps-Curl.gif'),
      const ExerciseImage(name: 'One Arm Cable Bicep Curl', imagePath: 'assets/exercise_images/Biceps/One-Arm-Cable-Bicep-Curl.gif', muscleGroup: 'Biceps', fileName: 'One-Arm-Cable-Bicep-Curl.gif'),
      const ExerciseImage(name: 'One Arm Cable Curl', imagePath: 'assets/exercise_images/Biceps/One-Arm-Cable-Curl.gif', muscleGroup: 'Biceps', fileName: 'One-Arm-Cable-Curl.gif'),
      const ExerciseImage(name: 'One Arm Chin Up', imagePath: 'assets/exercise_images/Biceps/One-Arm-Chin-Up.gif', muscleGroup: 'Biceps', fileName: 'One-Arm-Chin-Up.gif'),
      const ExerciseImage(name: 'One Arm Prone Dumbbell Curl', imagePath: 'assets/exercise_images/Biceps/One-Arm-Prone-Dumbbell-Curl.gif', muscleGroup: 'Biceps', fileName: 'One-Arm-Prone-Dumbbell-Curl.gif'),
      const ExerciseImage(name: 'Prone Incline Biceps Curl', imagePath: 'assets/exercise_images/Biceps/Prone-Incline-Biceps-Curl.gif', muscleGroup: 'Biceps', fileName: 'Prone-Incline-Biceps-Curl.gif'),
      const ExerciseImage(name: 'Seated Bicep Curl With Resistance Band', imagePath: 'assets/exercise_images/Biceps/Seated-Bicep-Curl-With-Resistance-Band.gif', muscleGroup: 'Biceps', fileName: 'Seated-Bicep-Curl-With-Resistance-Band.gif'),
      const ExerciseImage(name: 'Seated Incline Dumbbell Curl', imagePath: 'assets/exercise_images/Biceps/Seated-Incline-Dumbbell-Curl.gif', muscleGroup: 'Biceps', fileName: 'Seated-Incline-Dumbbell-Curl.gif'),
      const ExerciseImage(name: 'Seated Close Grip Concentration Curl', imagePath: 'assets/exercise_images/Biceps/Seated-close-grip-concentration-curl.gif', muscleGroup: 'Biceps', fileName: 'Seated-close-grip-concentration-curl.gif'),
      const ExerciseImage(name: 'Seated Dumbbell Alternating Curl', imagePath: 'assets/exercise_images/Biceps/Seated-dumbbell-alternating-curl.gif', muscleGroup: 'Biceps', fileName: 'Seated-dumbbell-alternating-curl.gif'),
      const ExerciseImage(name: 'Standing Barbell Concentration Curl', imagePath: 'assets/exercise_images/Biceps/Standing-Barbell-Concentration-Curl.gif', muscleGroup: 'Biceps', fileName: 'Standing-Barbell-Concentration-Curl.gif'),
      const ExerciseImage(name: 'Two Dumbbell Preacher Curl', imagePath: 'assets/exercise_images/Biceps/Two-dumbbell-preacher-curl.gif', muscleGroup: 'Biceps', fileName: 'Two-dumbbell-preacher-curl.gif'),
      const ExerciseImage(name: 'Z Bar Curl', imagePath: 'assets/exercise_images/Biceps/Z-Bar-Curl.gif', muscleGroup: 'Biceps', fileName: 'Z-Bar-Curl.gif'),
      const ExerciseImage(name: 'Z Bar Preacher Curl', imagePath: 'assets/exercise_images/Biceps/Z-Bar-Preacher-Curl.gif', muscleGroup: 'Biceps', fileName: 'Z-Bar-Preacher-Curl.gif'),
      const ExerciseImage(name: 'Cable Curl', imagePath: 'assets/exercise_images/Biceps/cable-curl.gif', muscleGroup: 'Biceps', fileName: 'cable-curl.gif'),
      const ExerciseImage(name: 'Cable Preacher Curls', imagePath: 'assets/exercise_images/Biceps/cable-preacher-curls.gif', muscleGroup: 'Biceps', fileName: 'cable-preacher-curls.gif'),
      const ExerciseImage(name: 'Close Grip Barbell Curl', imagePath: 'assets/exercise_images/Biceps/close-grip-barbell-curl.gif', muscleGroup: 'Biceps', fileName: 'close-grip-barbell-curl.gif'),
      const ExerciseImage(name: 'Dumbbell Scot Curl', imagePath: 'assets/exercise_images/Biceps/dumbbell-scot-curl.gif', muscleGroup: 'Biceps', fileName: 'dumbbell-scot-curl.gif'),
      const ExerciseImage(name: 'Elbow Flexion', imagePath: 'assets/exercise_images/Biceps/elbow-flexion.gif', muscleGroup: 'Biceps', fileName: 'elbow-flexion.gif'),
      const ExerciseImage(name: 'Lying Cable Curl', imagePath: 'assets/exercise_images/Biceps/lying-cable-curl.gif', muscleGroup: 'Biceps', fileName: 'lying-cable-curl.gif'),
      const ExerciseImage(name: 'Overhead Cable Curl', imagePath: 'assets/exercise_images/Biceps/overhead-cable-curl.gif', muscleGroup: 'Biceps', fileName: 'overhead-cable-curl.gif'),
      const ExerciseImage(name: 'Rope Bicep Curls', imagePath: 'assets/exercise_images/Biceps/rope-bicep-curls.gif', muscleGroup: 'Biceps', fileName: 'rope-bicep-curls.gif'),
      const ExerciseImage(name: 'Waiter Curl', imagePath: 'assets/exercise_images/Biceps/waiter-curl.gif', muscleGroup: 'Biceps', fileName: 'waiter-curl.gif'),
      const ExerciseImage(name: 'Zottman Curl', imagePath: 'assets/exercise_images/Biceps/zottman-curl.gif', muscleGroup: 'Biceps', fileName: 'zottman-curl.gif'),
    ];
  }

  // Cardio exercises - ALL actual exercises from the folder (46 exercises)
  static List<ExerciseImage> _getCardioExercises() {
    return [
      const ExerciseImage(name: '1 2 Stick Drill Plyometrics', imagePath: 'assets/exercise_images/Cardio/1-2-Stick-Drill-Plyometrics.gif', muscleGroup: 'Cardio', fileName: '1-2-Stick-Drill-Plyometrics.gif'),
      const ExerciseImage(name: 'Assault Air Runner', imagePath: 'assets/exercise_images/Cardio/Assault-Air-Runner.gif', muscleGroup: 'Cardio', fileName: 'Assault-Air-Runner.gif'),
      const ExerciseImage(name: 'Assault AirBike', imagePath: 'assets/exercise_images/Cardio/Assault-AirBike.gif', muscleGroup: 'Cardio', fileName: 'Assault-AirBike.gif'),
      const ExerciseImage(name: 'Astride Jumps', imagePath: 'assets/exercise_images/Cardio/Astride-Jumps.gif', muscleGroup: 'Cardio', fileName: 'Astride-Jumps.gif'),
      const ExerciseImage(name: 'Backwards Running', imagePath: 'assets/exercise_images/Cardio/Backwards-Running.gif', muscleGroup: 'Cardio', fileName: 'Backwards-Running.gif'),
      const ExerciseImage(name: 'Band Assisted Sprinter Run', imagePath: 'assets/exercise_images/Cardio/Band-Assisted-Sprinter-Run.gif', muscleGroup: 'Cardio', fileName: 'Band-Assisted-Sprinter-Run.gif'),
      const ExerciseImage(name: 'Boxer Shuffle Cardio', imagePath: 'assets/exercise_images/Cardio/Boxer-Shuffle-Cardio.gif', muscleGroup: 'Cardio', fileName: 'Boxer-Shuffle-Cardio.gif'),
      const ExerciseImage(name: 'Boxing Right Cross With Boxing Bag', imagePath: 'assets/exercise_images/Cardio/Boxing-Right-Cross-with-boxing-bag.gif', muscleGroup: 'Cardio', fileName: 'Boxing-Right-Cross-with-boxing-bag.gif'),
      const ExerciseImage(name: 'Briskly Walking', imagePath: 'assets/exercise_images/Cardio/Briskly-Walking.gif', muscleGroup: 'Cardio', fileName: 'Briskly-Walking.gif'),
      const ExerciseImage(name: 'Burpee Long Jump', imagePath: 'assets/exercise_images/Cardio/Burpee-Long-Jump.gif', muscleGroup: 'Cardio', fileName: 'Burpee-Long-Jump.gif'),
      const ExerciseImage(name: 'Butt Kicks', imagePath: 'assets/exercise_images/Cardio/Butt-Kicks.gif', muscleGroup: 'Cardio', fileName: 'Butt-Kicks.gif'),
      const ExerciseImage(name: 'Cross Body Push Up Plyometric', imagePath: 'assets/exercise_images/Cardio/Cross-Body-Push-up_Plyometric.gif', muscleGroup: 'Cardio', fileName: 'Cross-Body-Push-up_Plyometric.gif'),
      const ExerciseImage(name: 'Elbow To Knee Twists', imagePath: 'assets/exercise_images/Cardio/Elbow-To-Knee-Twists.gif', muscleGroup: 'Cardio', fileName: 'Elbow-To-Knee-Twists.gif'),
      const ExerciseImage(name: 'Elliptical Machine', imagePath: 'assets/exercise_images/Cardio/Elliptical-Machine.gif', muscleGroup: 'Cardio', fileName: 'Elliptical-Machine.gif'),
      const ExerciseImage(name: 'Fast Feet Run', imagePath: 'assets/exercise_images/Cardio/Fast-Feet-Run.gif', muscleGroup: 'Cardio', fileName: 'Fast-Feet-Run.gif'),
      const ExerciseImage(name: 'Hands Bike', imagePath: 'assets/exercise_images/Cardio/Hands-Bike.gif', muscleGroup: 'Cardio', fileName: 'Hands-Bike.gif'),
      const ExerciseImage(name: 'High Knees Against Wall', imagePath: 'assets/exercise_images/Cardio/High-Knees-against-wall.gif', muscleGroup: 'Cardio', fileName: 'High-Knees-against-wall.gif'),
      const ExerciseImage(name: 'Hook Kick Kickboxing With Boxing Bag', imagePath: 'assets/exercise_images/Cardio/Hook-Kick-Kickboxing-with-boxing-bag.gif', muscleGroup: 'Cardio', fileName: 'Hook-Kick-Kickboxing-with-boxing-bag.gif'),
      const ExerciseImage(name: 'Incline Treadmill', imagePath: 'assets/exercise_images/Cardio/Incline-Treadmill.gif', muscleGroup: 'Cardio', fileName: 'Incline-Treadmill.gif'),
      const ExerciseImage(name: 'Jab Boxing', imagePath: 'assets/exercise_images/Cardio/Jab-Boxing.gif', muscleGroup: 'Cardio', fileName: 'Jab-Boxing.gif'),
      const ExerciseImage(name: 'Jack Burpees', imagePath: 'assets/exercise_images/Cardio/Jack-Burpees.gif', muscleGroup: 'Cardio', fileName: 'Jack-Burpees.gif'),
      const ExerciseImage(name: 'Navy Seal Burpee', imagePath: 'assets/exercise_images/Cardio/Navy-Seal-Burpee.gif', muscleGroup: 'Cardio', fileName: 'Navy-Seal-Burpee.gif'),
      const ExerciseImage(name: 'Plyo Jacks', imagePath: 'assets/exercise_images/Cardio/Plyo-Jacks.gif', muscleGroup: 'Cardio', fileName: 'Plyo-Jacks.gif'),
      const ExerciseImage(name: 'Power Skips', imagePath: 'assets/exercise_images/Cardio/Power-Skips.gif', muscleGroup: 'Cardio', fileName: 'Power-Skips.gif'),
      const ExerciseImage(name: 'Punches', imagePath: 'assets/exercise_images/Cardio/Punches.gif', muscleGroup: 'Cardio', fileName: 'Punches.gif'),
      const ExerciseImage(name: 'Recumbent Exercise Bike', imagePath: 'assets/exercise_images/Cardio/Recumbent-Exercise-Bike.gif', muscleGroup: 'Cardio', fileName: 'Recumbent-Exercise-Bike.gif'),
      const ExerciseImage(name: 'Riding Outdoor Bicycle', imagePath: 'assets/exercise_images/Cardio/Riding-Outdoor-Bicycle.gif', muscleGroup: 'Cardio', fileName: 'Riding-Outdoor-Bicycle.gif'),
      const ExerciseImage(name: 'Right Uppercut Boxing', imagePath: 'assets/exercise_images/Cardio/Right-Uppercut-Boxing.gif', muscleGroup: 'Cardio', fileName: 'Right-Uppercut-Boxing.gif'),
      const ExerciseImage(name: 'Run In Place Exercise', imagePath: 'assets/exercise_images/Cardio/Run-in-Place-exercise.gif', muscleGroup: 'Cardio', fileName: 'Run-in-Place-exercise.gif'),
      const ExerciseImage(name: 'Run In Place', imagePath: 'assets/exercise_images/Cardio/Run-in-Place.gif', muscleGroup: 'Cardio', fileName: 'Run-in-Place.gif'),
      const ExerciseImage(name: 'Run', imagePath: 'assets/exercise_images/Cardio/Run.gif', muscleGroup: 'Cardio', fileName: 'Run.gif'),
      const ExerciseImage(name: 'Short Stride Run', imagePath: 'assets/exercise_images/Cardio/Short-Stride-Run.gif', muscleGroup: 'Cardio', fileName: 'Short-Stride-Run.gif'),
      const ExerciseImage(name: 'Side Shuttle', imagePath: 'assets/exercise_images/Cardio/Side-Shuttle.gif', muscleGroup: 'Cardio', fileName: 'Side-Shuttle.gif'),
      const ExerciseImage(name: 'Ski Step', imagePath: 'assets/exercise_images/Cardio/Ski-Step.gif', muscleGroup: 'Cardio', fileName: 'Ski-Step.gif'),
      const ExerciseImage(name: 'Skip Jump Rope', imagePath: 'assets/exercise_images/Cardio/Skip-Jump-Rope.gif', muscleGroup: 'Cardio', fileName: 'Skip-Jump-Rope.gif'),
      const ExerciseImage(name: 'Split Jacks', imagePath: 'assets/exercise_images/Cardio/Split-Jacks.gif', muscleGroup: 'Cardio', fileName: 'Split-Jacks.gif'),
      const ExerciseImage(name: 'Squat Tuck Jump', imagePath: 'assets/exercise_images/Cardio/Squat-Tuck-Jump.gif', muscleGroup: 'Cardio', fileName: 'Squat-Tuck-Jump.gif'),
      const ExerciseImage(name: 'Stationary Bike Run', imagePath: 'assets/exercise_images/Cardio/Stationary-Bike-Run.gif', muscleGroup: 'Cardio', fileName: 'Stationary-Bike-Run.gif'),
      const ExerciseImage(name: 'Tuck Jump', imagePath: 'assets/exercise_images/Cardio/Tuck-Jump.gif', muscleGroup: 'Cardio', fileName: 'Tuck-Jump.gif'),
      const ExerciseImage(name: 'Walk Wave Machine', imagePath: 'assets/exercise_images/Cardio/Walk-Wave-Machine.gif', muscleGroup: 'Cardio', fileName: 'Walk-Wave-Machine.gif'),
      const ExerciseImage(name: 'Walking High Knee Lunges', imagePath: 'assets/exercise_images/Cardio/Walking-High-Knee-Lunges.gif', muscleGroup: 'Cardio', fileName: 'Walking-High-Knee-Lunges.gif'),
      const ExerciseImage(name: 'Walking On Stepmill', imagePath: 'assets/exercise_images/Cardio/Walking-on-Stepmill.gif', muscleGroup: 'Cardio', fileName: 'Walking-on-Stepmill.gif'),
      const ExerciseImage(name: 'Walking', imagePath: 'assets/exercise_images/Cardio/Walking.gif', muscleGroup: 'Cardio', fileName: 'Walking.gif'),
      const ExerciseImage(name: 'Wheel Run', imagePath: 'assets/exercise_images/Cardio/Wheel-Run.gif', muscleGroup: 'Cardio', fileName: 'Wheel-Run.gif'),
      const ExerciseImage(name: 'Shadow Boxing Workout', imagePath: 'assets/exercise_images/Cardio/shadow-boxing-workout.gif', muscleGroup: 'Cardio', fileName: 'shadow-boxing-workout.gif'),
      const ExerciseImage(name: 'Sprint', imagePath: 'assets/exercise_images/Cardio/sprint.gif', muscleGroup: 'Cardio', fileName: 'sprint.gif'),
    ];
  }

  // Chest exercises - ALL actual exercises from the folder (71 exercises)
  static List<ExerciseImage> _getChestExercises() {
    return [
      const ExerciseImage(name: '10301301 Lever Pec Deck Fly Chest 720', imagePath: 'assets/exercise_images/chest/10301301-Lever-Pec-Deck-Fly_Chest_720.gif', muscleGroup: 'Chest', fileName: '10301301-Lever-Pec-Deck-Fly_Chest_720.gif'),
      const ExerciseImage(name: 'Above Head Chest Stretch', imagePath: 'assets/exercise_images/chest/Above-Head-Chest-Stretch.gif', muscleGroup: 'Chest', fileName: 'Above-Head-Chest-Stretch.gif'),
      const ExerciseImage(name: 'Alternate Dumbbell Bench Press', imagePath: 'assets/exercise_images/chest/Alternate-Dumbbell-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Alternate-Dumbbell-Bench-Press.gif'),
      const ExerciseImage(name: 'Assisted Chest Dip', imagePath: 'assets/exercise_images/chest/Assisted-Chest-Dip.gif', muscleGroup: 'Chest', fileName: 'Assisted-Chest-Dip.gif'),
      const ExerciseImage(name: 'Back Pec Stretch', imagePath: 'assets/exercise_images/chest/Back-Pec-Stretch.gif', muscleGroup: 'Chest', fileName: 'Back-Pec-Stretch.gif'),
      const ExerciseImage(name: 'Band Alternate Incline Chest Press', imagePath: 'assets/exercise_images/chest/Band-Alternate-Incline-Chest-Press-.gif', muscleGroup: 'Chest', fileName: 'Band-Alternate-Incline-Chest-Press-.gif'),
      const ExerciseImage(name: 'Band Standing Chest Press', imagePath: 'assets/exercise_images/chest/Band-Standing-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Band-Standing-Chest-Press.gif'),
      const ExerciseImage(name: 'Barbell Bench Press', imagePath: 'assets/exercise_images/chest/Barbell-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Barbell-Bench-Press.gif'),
      const ExerciseImage(name: 'Barbell Bent Arm Pullover', imagePath: 'assets/exercise_images/chest/Barbell-Bent-Arm-Pullover.gif', muscleGroup: 'Chest', fileName: 'Barbell-Bent-Arm-Pullover.gif'),
      const ExerciseImage(name: 'Barbell Floor Press', imagePath: 'assets/exercise_images/chest/Barbell-Floor-Press.gif', muscleGroup: 'Chest', fileName: 'Barbell-Floor-Press.gif'),
      const ExerciseImage(name: 'Cable Crossover', imagePath: 'assets/exercise_images/chest/Cable-Crossover.gif', muscleGroup: 'Chest', fileName: 'Cable-Crossover.gif'),
      const ExerciseImage(name: 'Cable Upper Chest Crossovers', imagePath: 'assets/exercise_images/chest/Cable-Upper-Chest-Crossovers.gif', muscleGroup: 'Chest', fileName: 'Cable-Upper-Chest-Crossovers.gif'),
      const ExerciseImage(name: 'Chest Dips', imagePath: 'assets/exercise_images/chest/Chest-Dips.gif', muscleGroup: 'Chest', fileName: 'Chest-Dips.gif'),
      const ExerciseImage(name: 'Chest Press Machine', imagePath: 'assets/exercise_images/chest/Chest-Press-Machine.gif', muscleGroup: 'Chest', fileName: 'Chest-Press-Machine.gif'),
      const ExerciseImage(name: 'Clap Push Up', imagePath: 'assets/exercise_images/chest/Clap-Push-Up.gif', muscleGroup: 'Chest', fileName: 'Clap-Push-Up.gif'),
      const ExerciseImage(name: 'Close Grip Incline Dumbbell Press', imagePath: 'assets/exercise_images/chest/Close-grip-Incline-Dumbbell-Press.gif', muscleGroup: 'Chest', fileName: 'Close-grip-Incline-Dumbbell-Press.gif'),
      const ExerciseImage(name: 'Decline Barbell Bench Press', imagePath: 'assets/exercise_images/chest/Decline-Barbell-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Decline-Barbell-Bench-Press.gif'),
      const ExerciseImage(name: 'Decline Cable Fly', imagePath: 'assets/exercise_images/chest/Decline-Cable-Fly.gif', muscleGroup: 'Chest', fileName: 'Decline-Cable-Fly.gif'),
      const ExerciseImage(name: 'Decline Chest Press Machine', imagePath: 'assets/exercise_images/chest/Decline-Chest-Press-Machine.gif', muscleGroup: 'Chest', fileName: 'Decline-Chest-Press-Machine.gif'),
      const ExerciseImage(name: 'Decline Dumbbell Fly', imagePath: 'assets/exercise_images/chest/Decline-Dumbbell-Fly.gif', muscleGroup: 'Chest', fileName: 'Decline-Dumbbell-Fly.gif'),
      const ExerciseImage(name: 'Decline Dumbbell Press', imagePath: 'assets/exercise_images/chest/Decline-Dumbbell-Press.gif', muscleGroup: 'Chest', fileName: 'Decline-Dumbbell-Press.gif'),
      const ExerciseImage(name: 'Decline Hammer Press', imagePath: 'assets/exercise_images/chest/Decline-hammer-press.gif', muscleGroup: 'Chest', fileName: 'Decline-hammer-press.gif'),
      const ExerciseImage(name: 'Drop Push Up', imagePath: 'assets/exercise_images/chest/Drop-Push-Up.gif', muscleGroup: 'Chest', fileName: 'Drop-Push-Up.gif'),
      const ExerciseImage(name: 'Dumbbell Fly', imagePath: 'assets/exercise_images/chest/Dumbbell-Fly.gif', muscleGroup: 'Chest', fileName: 'Dumbbell-Fly.gif'),
      const ExerciseImage(name: 'Dumbbell One Arm Reverse Grip Press', imagePath: 'assets/exercise_images/chest/Dumbbell-One-Arm-Reverse-Grip-Press.gif', muscleGroup: 'Chest', fileName: 'Dumbbell-One-Arm-Reverse-Grip-Press.gif'),
      const ExerciseImage(name: 'Dumbbell Press', imagePath: 'assets/exercise_images/chest/Dumbbell-Press-1.gif', muscleGroup: 'Chest', fileName: 'Dumbbell-Press-1.gif'),
      const ExerciseImage(name: 'Dumbbell Pullover On Stability Ball', imagePath: 'assets/exercise_images/chest/Dumbbell-Pullover-On-Stability-Ball.gif', muscleGroup: 'Chest', fileName: 'Dumbbell-Pullover-On-Stability-Ball.gif'),
      const ExerciseImage(name: 'Dumbbell Pullover', imagePath: 'assets/exercise_images/chest/Dumbbell-Pullover.gif', muscleGroup: 'Chest', fileName: 'Dumbbell-Pullover.gif'),
      const ExerciseImage(name: 'Dumbbell Upward Fly', imagePath: 'assets/exercise_images/chest/Dumbbell-Upward-Fly.gif', muscleGroup: 'Chest', fileName: 'Dumbbell-Upward-Fly.gif'),
      const ExerciseImage(name: 'Dynamic Chest Stretch', imagePath: 'assets/exercise_images/chest/Dynamic-Chest-Stretch.gif', muscleGroup: 'Chest', fileName: 'Dynamic-Chest-Stretch.gif'),
      const ExerciseImage(name: 'Foam Roller Chest Stretch', imagePath: 'assets/exercise_images/chest/Foam-Roller-Chest-Stretch.gif', muscleGroup: 'Chest', fileName: 'Foam-Roller-Chest-Stretch.gif'),
      const ExerciseImage(name: 'Hammer Press', imagePath: 'assets/exercise_images/chest/Hammer-Press.gif', muscleGroup: 'Chest', fileName: 'Hammer-Press.gif'),
      const ExerciseImage(name: 'High Cable Crossover', imagePath: 'assets/exercise_images/chest/High-Cable-Crossover.gif', muscleGroup: 'Chest', fileName: 'High-Cable-Crossover.gif'),
      const ExerciseImage(name: 'Incline Barbell Bench Press', imagePath: 'assets/exercise_images/chest/Incline-Barbell-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Incline-Barbell-Bench-Press.gif'),
      const ExerciseImage(name: 'Incline Cable Fly', imagePath: 'assets/exercise_images/chest/Incline-Cable-Fly.gif', muscleGroup: 'Chest', fileName: 'Incline-Cable-Fly.gif'),
      const ExerciseImage(name: 'Incline Chest Fly Machine', imagePath: 'assets/exercise_images/chest/Incline-Chest-Fly-Machine.gif', muscleGroup: 'Chest', fileName: 'Incline-Chest-Fly-Machine.gif'),
      const ExerciseImage(name: 'Incline Chest Press Machine', imagePath: 'assets/exercise_images/chest/Incline-Chest-Press-Machine.gif', muscleGroup: 'Chest', fileName: 'Incline-Chest-Press-Machine.gif'),
      const ExerciseImage(name: 'Incline Close Grip Bench Press', imagePath: 'assets/exercise_images/chest/Incline-Close-Grip-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Incline-Close-Grip-Bench-Press.gif'),
      const ExerciseImage(name: 'Incline Dumbbell Hammer Press', imagePath: 'assets/exercise_images/chest/Incline-Dumbbel-Hammer-Press.gif', muscleGroup: 'Chest', fileName: 'Incline-Dumbbel-Hammer-Press.gif'),
      const ExerciseImage(name: 'Incline Dumbbell Press', imagePath: 'assets/exercise_images/chest/Incline-Dumbbell-Press.gif', muscleGroup: 'Chest', fileName: 'Incline-Dumbbell-Press.gif'),
      const ExerciseImage(name: 'Incline Push Up', imagePath: 'assets/exercise_images/chest/Incline-Push-Up.gif', muscleGroup: 'Chest', fileName: 'Incline-Push-Up.gif'),
      const ExerciseImage(name: 'Incline Dumbbell Fly', imagePath: 'assets/exercise_images/chest/Incline-dumbbell-Fly.gif', muscleGroup: 'Chest', fileName: 'Incline-dumbbell-Fly.gif'),
      const ExerciseImage(name: 'Inner Chest Press Machine', imagePath: 'assets/exercise_images/chest/Inner-Chest-Press-Machine.gif', muscleGroup: 'Chest', fileName: 'Inner-Chest-Press-Machine.gif'),
      const ExerciseImage(name: 'Kettlebell Chest Press On The Floor', imagePath: 'assets/exercise_images/chest/Kettlebell-Chest-Press-on-the-Floor.gif', muscleGroup: 'Chest', fileName: 'Kettlebell-Chest-Press-on-the-Floor.gif'),
      const ExerciseImage(name: 'Kneeling Push Up', imagePath: 'assets/exercise_images/chest/Kneeling-Push-up.gif', muscleGroup: 'Chest', fileName: 'Kneeling-Push-up.gif'),
      const ExerciseImage(name: 'Landmine Floor Chest Fly', imagePath: 'assets/exercise_images/chest/Landmine-Floor-Chest-Fly.gif', muscleGroup: 'Chest', fileName: 'Landmine-Floor-Chest-Fly.gif'),
      const ExerciseImage(name: 'Lever Chest Press', imagePath: 'assets/exercise_images/chest/Lever-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Lever-Chest-Press.gif'),
      const ExerciseImage(name: 'Lever Crossovers', imagePath: 'assets/exercise_images/chest/Lever-Crossovers.gif', muscleGroup: 'Chest', fileName: 'Lever-Crossovers.gif'),
      const ExerciseImage(name: 'Lever Decline Chest Press', imagePath: 'assets/exercise_images/chest/Lever-Decline-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Lever-Decline-Chest-Press.gif'),
      const ExerciseImage(name: 'Lever Incline Chest Press', imagePath: 'assets/exercise/images/chest/Lever-Incline-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Lever-Incline-Chest-Press.gif'),
      const ExerciseImage(name: 'Lever Incline Hammer Chest Press', imagePath: 'assets/exercise_images/chest/Lever-Incline-Hammer-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Lever-Incline-Hammer-Chest-Press.gif'),
      const ExerciseImage(name: 'Lever One Arm Chest Press', imagePath: 'assets/exercise_images/chest/Lever-One-Arm-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Lever-One-Arm-Chest-Press.gif'),
      const ExerciseImage(name: 'Low Cable Crossover', imagePath: 'assets/exercise_images/chest/Low-Cable-Crossover.gif', muscleGroup: 'Chest', fileName: 'Low-Cable-Crossover.gif'),
      const ExerciseImage(name: 'Lying Cable Fly', imagePath: 'assets/exercise_images/chest/Lying-Cable-Fly.gif', muscleGroup: 'Chest', fileName: 'Lying-Cable-Fly.gif'),
      const ExerciseImage(name: 'Lying Chest Press Machine', imagePath: 'assets/exercise_images/chest/Lying-Chest-Press-Machine.gif', muscleGroup: 'Chest', fileName: 'Lying-Chest-Press-Machine.gif'),
      const ExerciseImage(name: 'Lying Extension Pullover', imagePath: 'assets/exercise_images/chest/Lying-Extension-Pullover.gif', muscleGroup: 'Chest', fileName: 'Lying-Extension-Pullover.gif'),
      const ExerciseImage(name: 'One Arm Cable Chest Press', imagePath: 'assets/exercise_images/chest/One-Arm-Cable-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'One-Arm-Cable-Chest-Press.gif'),
      const ExerciseImage(name: 'One Arm Decline Cable Fly', imagePath: 'assets/exercise_images/chest/One-Arm-Decline-Cable-Fly.gif', muscleGroup: 'Chest', fileName: 'One-Arm-Decline-Cable-Fly.gif'),
      const ExerciseImage(name: 'One Arm Kettlebell Chest Press On The Bench', imagePath: 'assets/exercise_images/chest/One-Arm-Kettlebell-Chest-Press-on-the-Bench.gif', muscleGroup: 'Chest', fileName: 'One-Arm-Kettlebell-Chest-Press-on-the-Bench.gif'),
      const ExerciseImage(name: 'One Arm Push Ups With Support', imagePath: 'assets/exercise_images/chest/One-Arm-Push-Ups-With-Support.gif', muscleGroup: 'Chest', fileName: 'One-Arm-Push-Ups-With-Support.gif'),
      const ExerciseImage(name: 'Pec Deck Fly', imagePath: 'assets/exercise_images/chest/Pec-Deck-Fly.gif', muscleGroup: 'Chest', fileName: 'Pec-Deck-Fly.gif'),
      const ExerciseImage(name: 'Push Up Medicine Ball', imagePath: 'assets/exercise_images/chest/Push-Up-Medicine-Ball.gif', muscleGroup: 'Chest', fileName: 'Push-Up-Medicine-Ball.gif'),
      const ExerciseImage(name: 'Push Up', imagePath: 'assets/exercise_images/chest/Push-Up.gif', muscleGroup: 'Chest', fileName: 'Push-Up.gif'),
      const ExerciseImage(name: 'Push Up With Push Up Bars', imagePath: 'assets/exercise_images/chest/Push-up-With-Push-up-Bars.gif', muscleGroup: 'Chest', fileName: 'Push-up-With-Push-up-Bars.gif'),
      const ExerciseImage(name: 'Reverse Chest Stretch', imagePath: 'assets/exercise_images/chest/Reverse-Chest-Stretch.gif', muscleGroup: 'Chest', fileName: 'Reverse-Chest-Stretch.gif'),
      const ExerciseImage(name: 'Reverse Grip Dumbbell Bench Press', imagePath: 'assets/exercise_images/chest/Reverse-Grip-Dumbbell-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Reverse-Grip-Dumbbell-Bench-Press.gif'),
      const ExerciseImage(name: 'Reverse Grip Incline Dumbbell Press', imagePath: 'assets/exercise_images/chest/Reverse-Grip-Incline-Dumbbell-Press.gif', muscleGroup: 'Chest', fileName: 'Reverse-Grip-Incline-Dumbbell-Press.gif'),
      const ExerciseImage(name: 'Seated Cable Chest Press', imagePath: 'assets/exercise_images/chest/Seated-Cable-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Seated-Cable-Chest-Press.gif'),
      const ExerciseImage(name: 'Seated Cable Close Grip Chest Press', imagePath: 'assets/exercise_images/chest/Seated-Cable-Close-Grip-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Seated-Cable-Close-Grip-Chest-Press.gif'),
      const ExerciseImage(name: 'Seated Chest Stretch', imagePath: 'assets/exercise_images/chest/Seated-Chest-Stretch.gif', muscleGroup: 'Chest', fileName: 'Seated-Chest-Stretch.gif'),
      const ExerciseImage(name: 'Single Arm Cable Crossover', imagePath: 'assets/exercise_images/chest/Single-Arm-Cable-Crossover.gif', muscleGroup: 'Chest', fileName: 'Single-Arm-Cable-Crossover.gif'),
      const ExerciseImage(name: 'Smith Machine Bench Press', imagePath: 'assets/exercise_images/chest/Smith-Machine-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Smith-Machine-Bench-Press.gif'),
      const ExerciseImage(name: 'Smith Machine Decline Bench Press', imagePath: 'assets/exercise_images/chest/Smith-Machine-Decline-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Smith-Machine-Decline-Bench-Press.gif'),
      const ExerciseImage(name: 'Smith Machine Hex Press', imagePath: 'assets/exercise_images/chest/Smith-Machine-Hex-Press.gif', muscleGroup: 'Chest', fileName: 'Smith-Machine-Hex-Press.gif'),
      const ExerciseImage(name: 'Smith Machine Incline Bench Press', imagePath: 'assets/exercise_images/chest/Smith-Machine-Incline-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Smith-Machine-Incline-Bench-Press.gif'),
      const ExerciseImage(name: 'Svend Press', imagePath: 'assets/exercise_images/chest/Svend-Press.gif', muscleGroup: 'Chest', fileName: 'Svend-Press.gif'),
      const ExerciseImage(name: 'Trx Chest Press', imagePath: 'assets/exercise_images/chest/Trx-Chest-Press.gif', muscleGroup: 'Chest', fileName: 'Trx-Chest-Press.gif'),
      const ExerciseImage(name: 'Weighted Push Up', imagePath: 'assets/exercise_images/chest/Weighted-Push-up.gif', muscleGroup: 'Chest', fileName: 'Weighted-Push-up.gif'),
      const ExerciseImage(name: 'Wide Grip Barbell Bench Press', imagePath: 'assets/exercise_images/chest/Wide-Grip-Barbell-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Wide-Grip-Barbell-Bench-Press.gif'),
      const ExerciseImage(name: 'Wide Grip Reverse Bench Press', imagePath: 'assets/exercise_images/chest/Wide-Grip-Reverse-Bench-Press.gif', muscleGroup: 'Chest', fileName: 'Wide-Grip-Reverse-Bench-Press.gif'),
      const ExerciseImage(name: 'Push Up With Rotation', imagePath: 'assets/exercise_images/chest/push-up-with-rotation.gif', muscleGroup: 'Chest', fileName: 'push-up-with-rotation.gif'),
      const ExerciseImage(name: 'Stability Ball Decline Push Ups', imagePath: 'assets/exercise_images/chest/stability-ball-decline-push-ups.gif', muscleGroup: 'Chest', fileName: 'stability-ball-decline-push-ups.gif'),
      const ExerciseImage(name: 'Stability Ball Push Up', imagePath: 'assets/exercise_images/chest/stability-ball-push-up.gif', muscleGroup: 'Chest', fileName: 'stability-ball-push-up.gif'),
    ];
  }

  // Erector Spinae exercises - ALL actual exercises from the folder (23 exercises)
  static List<ExerciseImage> _getErectorSpinaeExercises() {
    return [
      const ExerciseImage(name: 'Barbell Pendlay Row', imagePath: 'assets/exercise_images/Erector spinae/Barbell-Pendlay-Row.gif', muscleGroup: 'Erector Spinae', fileName: 'Barbell-Pendlay-Row.gif'),
      const ExerciseImage(name: 'Barbell Romanian Deadlift', imagePath: 'assets/exercise_images/Erector spinae/Barbell-Romanian-Deadlift.gif', muscleGroup: 'Erector Spinae', fileName: 'Barbell-Romanian-Deadlift.gif'),
      const ExerciseImage(name: 'Barbell Sumo Deadlift', imagePath: 'assets/exercise_images/Erector spinae/Barbell-Sumo-Deadlift.gif', muscleGroup: 'Erector Spinae', fileName: 'Barbell-Sumo-Deadlift.gif'),
      const ExerciseImage(name: 'Bird Dog', imagePath: 'assets/exercise_images/Erector spinae/Bird-Dog.gif', muscleGroup: 'Erector Spinae', fileName: 'Bird-Dog.gif'),
      const ExerciseImage(name: 'Dumbbell Romanian Deadlift', imagePath: 'assets/exercise_images/Erector spinae/Dumbbell-Romanian-Deadlift.gif', muscleGroup: 'Erector Spinae', fileName: 'Dumbbell-Romanian-Deadlift.gif'),
      const ExerciseImage(name: 'Flat Bench Hyperextension', imagePath: 'assets/exercise_images/Erector spinae/Flat-Bench-Hyperextension.gif', muscleGroup: 'Erector Spinae', fileName: 'Flat-Bench-Hyperextension.gif'),
      const ExerciseImage(name: 'Kettlebell Figure 8', imagePath: 'assets/exercise_images/Erector spinae/Kettlebell-Figure-8.gif', muscleGroup: 'Erector Spinae', fileName: 'Kettlebell-Figure-8.gif'),
      const ExerciseImage(name: 'Kettlebell Single Leg Deadlift', imagePath: 'assets/exercise_images/Erector spinae/Kettlebell-Single-Leg-Deadlift.gif', muscleGroup: 'Erector Spinae', fileName: 'Kettlebell-Single-Leg-Deadlift.gif'),
      const ExerciseImage(name: 'Reverse Hyperextension Machine', imagePath: 'assets/exercise_images/Erector spinae/Reverse-Hyperextension-Machine.gif', muscleGroup: 'Erector Spinae', fileName: 'Reverse-Hyperextension-Machine.gif'),
      const ExerciseImage(name: 'Reverse Hyperextensions', imagePath: 'assets/exercise_images/Erector spinae/Reverse-Hyperextensions.gif', muscleGroup: 'Erector Spinae', fileName: 'Reverse-Hyperextensions.gif'),
      const ExerciseImage(name: 'Roll Upper Back', imagePath: 'assets/exercise_images/Erector spinae/Roll-Upper-Back.gif', muscleGroup: 'Erector Spinae', fileName: 'Roll-Upper-Back.gif'),
      const ExerciseImage(name: 'Rolling Like A Ball Crab', imagePath: 'assets/exercise_images/Erector spinae/Rolling-Like-a-Ball-crab.gif', muscleGroup: 'Erector Spinae', fileName: 'Rolling-Like-a-Ball-crab.gif'),
      const ExerciseImage(name: 'Seated Cable Rope Row', imagePath: 'assets/exercise_images/Erector spinae/Seated-Cable-Rope-Row.gif', muscleGroup: 'Erector Spinae', fileName: 'Seated-Cable-Rope-Row.gif'),
      const ExerciseImage(name: 'Standing Toe Touches', imagePath: 'assets/exercise_images/Erector spinae/Standing-Toe-Touches.gif', muscleGroup: 'Erector Spinae', fileName: 'Standing-Toe-Touches.gif'),
      const ExerciseImage(name: 'Supine Spinal Twist', imagePath: 'assets/exercise_images/Erector spinae/Supine-Spinal-Twist.gif', muscleGroup: 'Erector Spinae', fileName: 'Supine-Spinal-Twist.gif'),
      const ExerciseImage(name: 'Twisting Hyperextension', imagePath: 'assets/exercise_images/Erector spinae/Twisting-Hyperextension.gif', muscleGroup: 'Erector Spinae', fileName: 'Twisting-Hyperextension.gif'),
      const ExerciseImage(name: 'Weighted Back Extension', imagePath: 'assets/exercise_images/Erector spinae/Weighted-Back-Extension.gif', muscleGroup: 'Erector Spinae', fileName: 'Weighted-Back-Extension.gif'),
      const ExerciseImage(name: 'Cat Cow', imagePath: 'assets/exercise_images/Erector spinae/cat-cow.gif', muscleGroup: 'Erector Spinae', fileName: 'cat-cow.gif'),
      const ExerciseImage(name: 'Hyperextension', imagePath: 'assets/exercise_images/Erector spinae/hyperextension.gif', muscleGroup: 'Erector Spinae', fileName: 'hyperextension.gif'),
      const ExerciseImage(name: 'Kettlebell Deadlift', imagePath: 'assets/exercise_images/Erector spinae/kettlebell-deadlift.gif', muscleGroup: 'Erector Spinae', fileName: 'kettlebell-deadlift.gif'),
      const ExerciseImage(name: 'Seated Back Extension', imagePath: 'assets/exercise_images/Erector spinae/seated-back-extension.gif', muscleGroup: 'Erector Spinae', fileName: 'seated-back-extension.gif'),
      const ExerciseImage(name: 'T Bar Rows', imagePath: 'assets/exercise_images/Erector spinae/t-bar-rows (1).gif', muscleGroup: 'Erector Spinae', fileName: 't-bar-rows (1).gif'),
      const ExerciseImage(name: 'T Bar Rows', imagePath: 'assets/exercise_images/Erector spinae/t-bar-rows.gif', muscleGroup: 'Erector Spinae', fileName: 't-bar-rows.gif'),
      const ExerciseImage(name: 'Deadlift', imagePath: 'assets/exercise_images/Erector spinae/deadlift.gif', muscleGroup: 'Erector Spinae', fileName: 'deadlift.gif'),
    ];
  }

  // Full Body exercises - ALL actual exercises from the folder (48 exercises)
  static List<ExerciseImage> _getFullBodyExercises() {
    return [
      const ExerciseImage(name: 'Archer Pull Up', imagePath: 'assets/exercise_images/Full Body/Archer-Pull-up.gif', muscleGroup: 'Full Body', fileName: 'Archer-Pull-up.gif'),
      const ExerciseImage(name: 'Back Lever', imagePath: 'assets/exercise_images/Full Body/Back-Lever (1).gif', muscleGroup: 'Full Body', fileName: 'Back-Lever (1).gif'),
      const ExerciseImage(name: 'Backward Medicine Ball Throw', imagePath: 'assets/exercise_images/Full Body/Backward-Medicine-Ball-Throw.gif', muscleGroup: 'Full Body', fileName: 'Backward-Medicine-Ball-Throw.gif'),
      const ExerciseImage(name: 'Barbell Bent Over Row', imagePath: 'assets/exercise_images/Full Body/Barbell-Bent-Over-Row.gif', muscleGroup: 'Full Body', fileName: 'Barbell-Bent-Over-Row.gif'),
      const ExerciseImage(name: 'Barbell Hang Clean', imagePath: 'assets/exercise_images/Full Body/Barbell-Hang-Clean.gif', muscleGroup: 'Full Body', fileName: 'Barbell-Hang-Clean.gif'),
      const ExerciseImage(name: 'Barbell Heaving Snatch Balance', imagePath: 'assets/exercise_images/Full Body/Barbell-Heaving-Snatch-Balance.gif', muscleGroup: 'Full Body', fileName: 'Barbell-Heaving-Snatch-Balance.gif'),
      const ExerciseImage(name: 'Barbell Muscle Snatch', imagePath: 'assets/exercise_images/Full Body/Barbell-Muscle-Snatch.gif', muscleGroup: 'Full Body', fileName: 'Barbell-Muscle-Snatch.gif'),
      const ExerciseImage(name: 'Barbell Snatch', imagePath: 'assets/exercise_images/Full Body/Barbell-Snatch.gif', muscleGroup: 'Full Body', fileName: 'Barbell-Snatch.gif'),
      const ExerciseImage(name: 'Bear Crawl', imagePath: 'assets/exercise_images/Full Body/Bear-Crawl.gif', muscleGroup: 'Full Body', fileName: 'Bear-Crawl.gif'),
      const ExerciseImage(name: 'Bent Over Dumbbell Row', imagePath: 'assets/exercise_images/Full Body/Bent-Over-Dumbbell-Row.gif', muscleGroup: 'Full Body', fileName: 'Bent-Over-Dumbbell-Row.gif'),
      const ExerciseImage(name: 'Burpee Long Jump', imagePath: 'assets/exercise_images/Full Body/Burpee-Long-Jump (1).gif', muscleGroup: 'Full Body', fileName: 'Burpee-Long-Jump (1).gif'),
      const ExerciseImage(name: 'Burpee With Push Up', imagePath: 'assets/exercise_images/Full Body/Burpee-with-Push-Up.gif', muscleGroup: 'Full Body', fileName: 'Burpee-with-Push-Up.gif'),
      const ExerciseImage(name: 'Climbing Monkey Bars', imagePath: 'assets/exercise_images/Full Body/Climbing-Monkey-Bars.gif', muscleGroup: 'Full Body', fileName: 'Climbing-Monkey-Bars.gif'),
      const ExerciseImage(name: 'Dumbbell Burpees', imagePath: 'assets/exercise_images/Full Body/Dumbbell-Burpees.gif', muscleGroup: 'Full Body', fileName: 'Dumbbell-Burpees.gif'),
      const ExerciseImage(name: 'Dumbbell Devil Press', imagePath: 'assets/exercise_images/Full Body/Dumbbell-Devil-Press.gif', muscleGroup: 'Full Body', fileName: 'Dumbbell-Devil-Press.gif'),
      const ExerciseImage(name: 'Dumbbell Power Clean', imagePath: 'assets/exercise_images/Full Body/Dumbbell-Power-Clean.gif', muscleGroup: 'Full Body', fileName: 'Dumbbell-Power-Clean.gif'),
      const ExerciseImage(name: 'Farmers Walk Cardio', imagePath: 'assets/exercise_images/Full Body/Farmers-walk_Cardio.gif', muscleGroup: 'Full Body', fileName: 'Farmers-walk_Cardio.gif'),
      const ExerciseImage(name: 'Front Lever Pull Up', imagePath: 'assets/exercise_images/Full Body/Front-Lever-Pull-up.gif', muscleGroup: 'Full Body', fileName: 'Front-Lever-Pull-up.gif'),
      const ExerciseImage(name: 'Full Planche', imagePath: 'assets/exercise_images/Full Body/Full-Planche.gif', muscleGroup: 'Full Body', fileName: 'Full-Planche.gif'),
      const ExerciseImage(name: 'Human Flag', imagePath: 'assets/exercise_images/Full Body/Human-Flag.gif', muscleGroup: 'Full Body', fileName: 'Human-Flag.gif'),
      const ExerciseImage(name: 'Kettlebell Hang Clean', imagePath: 'assets/exercise_images/Full Body/Kettlebell-Hang-Clean.gif', muscleGroup: 'Full Body', fileName: 'Kettlebell-Hang-Clean.gif'),
      const ExerciseImage(name: 'Kettlebell Renegade Row', imagePath: 'assets/exercise_images/Full Body/Kettlebell-Renegade-Row.gif', muscleGroup: 'Full Body', fileName: 'Kettlebell-Renegade-Row.gif'),
      const ExerciseImage(name: 'L Pull Up', imagePath: 'assets/exercise_images/Full Body/L-Pull-Up.gif', muscleGroup: 'Full Body', fileName: 'L-Pull-Up.gif'),
      const ExerciseImage(name: 'Log Lift', imagePath: 'assets/exercise_images/Full Body/Log-Lift.gif', muscleGroup: 'Full Body', fileName: 'Log-Lift.gif'),
      const ExerciseImage(name: 'Modified Hindu Push Up', imagePath: 'assets/exercise_images/Full Body/Modified-Hindu-Push-up.gif', muscleGroup: 'Full Body', fileName: 'Modified-Hindu-Push-up.gif'),
      const ExerciseImage(name: 'Muscle Up Vertical Bar', imagePath: 'assets/exercise_images/Full Body/Muscle-up-vertical-bar.gif', muscleGroup: 'Full Body', fileName: 'Muscle-up-vertical-bar.gif'),
      const ExerciseImage(name: 'Power Clean', imagePath: 'assets/exercise_images/Full Body/Power-Clean-.gif', muscleGroup: 'Full Body', fileName: 'Power-Clean-.gif'),
      const ExerciseImage(name: 'Push Up To Renegade Row', imagePath: 'assets/exercise_images/Full Body/Push-Up-to-Renegade-Row.gif', muscleGroup: 'Full Body', fileName: 'Push-Up-to-Renegade-Row.gif'),
      const ExerciseImage(name: 'Push Up Toe Touch', imagePath: 'assets/exercise_images/Full Body/Push-up-Toe-Touch.gif', muscleGroup: 'Full Body', fileName: 'Push-up-Toe-Touch.gif'),
      const ExerciseImage(name: 'Ring Dips', imagePath: 'assets/exercise_images/Full Body/Ring-Dips (1).gif', muscleGroup: 'Full Body', fileName: 'Ring-Dips (1).gif'),
      const ExerciseImage(name: 'Rope Climb', imagePath: 'assets/exercise_images/Full Body/Rope-Climb.gif', muscleGroup: 'Full Body', fileName: 'Rope-Climb.gif'),
      const ExerciseImage(name: 'Ski Ergometer', imagePath: 'assets/exercise_images/Full Body/Ski-Ergometer.gif', muscleGroup: 'Full Body', fileName: 'Ski-Ergometer.gif'),
      const ExerciseImage(name: 'Step Behind Rotational Med Ball Throw', imagePath: 'assets/exercise_images/Full Body/Step-Behind-Rotational-Med-Ball-Throw.gif', muscleGroup: 'Full Body', fileName: 'Step-Behind-Rotational-Med-Ball-Throw.gif'),
      const ExerciseImage(name: 'Straddle Planche', imagePath: 'assets/exercise_images/Full Body/Straddle-Planche.gif', muscleGroup: 'Full Body', fileName: 'Straddle-Planche.gif'),
      const ExerciseImage(name: 'StrongMan Tire Flip', imagePath: 'assets/exercise_images/Full Body/StrongMan-Tire-Flip.gif', muscleGroup: 'Full Body', fileName: 'StrongMan-Tire-Flip.gif'),
      const ExerciseImage(name: 'Tire SledgeHammer', imagePath: 'assets/exercise_images/Full Body/Tire-SledgeHammer.gif', muscleGroup: 'Full Body', fileName: 'Tire-SledgeHammer.gif'),
      const ExerciseImage(name: 'Turkish Get Up Squat Style', imagePath: 'assets/exercise_images/Full Body/Turkish-Get-Up-Squat-style.gif', muscleGroup: 'Full Body', fileName: 'Turkish-Get-Up-Squat-style.gif'),
      const ExerciseImage(name: 'Body Saw Plank', imagePath: 'assets/exercise_images/Full Body/body-saw-plank.gif', muscleGroup: 'Full Body', fileName: 'body-saw-plank.gif'),
      const ExerciseImage(name: 'Clean And Jerk', imagePath: 'assets/exercise_images/Full Body/clean-and-jerk.gif', muscleGroup: 'Full Body', fileName: 'clean-and-jerk.gif'),
      const ExerciseImage(name: 'Dumbbell Renegade Row', imagePath: 'assets/exercise_images/Full Body/dumbbell-renegade-row-1.gif', muscleGroup: 'Full Body', fileName: 'dumbbell-renegade-row-1.gif'),
      const ExerciseImage(name: 'Handstand Holds', imagePath: 'assets/exercise_images/Full Body/handstand-holds.gif', muscleGroup: 'Full Body', fileName: 'handstand-holds.gif'),
      const ExerciseImage(name: 'Handstand Walk', imagePath: 'assets/exercise_images/Full Body/handstand-walk.gif', muscleGroup: 'Full Body', fileName: 'handstand-walk.gif'),
      const ExerciseImage(name: 'Lean Planche', imagePath: 'assets/exercise_images/Full Body/lean-planche-360x360.png', muscleGroup: 'Full Body', fileName: 'lean-planche-360x360.png'),
      const ExerciseImage(name: 'Overhead Squat', imagePath: 'assets/exercise_images/Full Body/overhead-squat.gif', muscleGroup: 'Full Body', fileName: 'overhead-squat.gif'),
      const ExerciseImage(name: 'Plate Push', imagePath: 'assets/exercise_images/Full Body/plate-push.gif', muscleGroup: 'Full Body', fileName: 'plate-push.gif'),
      const ExerciseImage(name: 'Wall Walk Muscles', imagePath: 'assets/exercise_images/Full Body/wall-walk-muscles.gif', muscleGroup: 'Full Body', fileName: 'wall-walk-muscles.gif'),
      const ExerciseImage(name: 'Zercher Carry', imagePath: 'assets/exercise_images/Full Body/zercher-carry.gif', muscleGroup: 'Full Body', fileName: 'zercher-carry.gif'),
    ];
  }

  // Neck exercises - ALL actual exercises from the folder (25 exercises)
  static List<ExerciseImage> _getNeckExercises() {
    return [
      const ExerciseImage(name: 'Cable Seated Neck Extension With Head Harness', imagePath: 'assets/exercise_images/neck/Cable-Seated-Neck-Extension-with-head-harness.gif', muscleGroup: 'Neck', fileName: 'Cable-Seated-Neck-Extension-with-head-harness.gif'),
      const ExerciseImage(name: 'Cable Seated Neck Flexion With Head Harness', imagePath: 'assets/exercise_images/neck/Cable-Seated-Neck-Flexion-with-head-harness.gif', muscleGroup: 'Neck', fileName: 'Cable-Seated-Neck-Flexion-with-head-harness.gif'),
      const ExerciseImage(name: 'Chin Tuck', imagePath: 'assets/exercise_images/neck/Chin-Tuck.gif', muscleGroup: 'Neck', fileName: 'Chin-Tuck.gif'),
      const ExerciseImage(name: 'Diagonal Neck Stretch', imagePath: 'assets/exercise_images/neck/Diagonal-Neck-Stretch-360x360.png', muscleGroup: 'Neck', fileName: 'Diagonal-Neck-Stretch-360x360.png'),
      const ExerciseImage(name: 'Fish Pose Matsyasana', imagePath: 'assets/exercise_images/neck/Fish-Pose-Matsyasana.gif', muscleGroup: 'Neck', fileName: 'Fish-Pose-Matsyasana.gif'),
      const ExerciseImage(name: 'Floor Hyperextension', imagePath: 'assets/exercise_images/neck/Floor-Hyperextension-1.gif', muscleGroup: 'Neck', fileName: 'Floor-Hyperextension-1.gif'),
      const ExerciseImage(name: 'Front And Back Neck Stretch', imagePath: 'assets/exercise_images/neck/Front-and-Back-Neck-Stretch.gif', muscleGroup: 'Neck', fileName: 'Front-and-Back-Neck-Stretch.gif'),
      const ExerciseImage(name: 'Kneeling Neck Stretch', imagePath: 'assets/exercise_images/neck/Kneeling-Neck-Stretch.gif', muscleGroup: 'Neck', fileName: 'Kneeling-Neck-Stretch.gif'),
      const ExerciseImage(name: 'Lever Neck Extension Plate Loaded', imagePath: 'assets/exercise_images/neck/Lever-Neck-Extension-plate-loaded.gif', muscleGroup: 'Neck', fileName: 'Lever-Neck-Extension-plate-loaded.gif'),
      const ExerciseImage(name: 'Lever Neck Right Side Flexion Plate Loaded', imagePath: 'assets/exercise_images/neck/Lever-Neck-Right-Side-Flexion-plate-loaded.gif', muscleGroup: 'Neck', fileName: 'Lever-Neck-Right-Side-Flexion-plate-loaded.gif'),
      const ExerciseImage(name: 'Lying Weighted Lateral Neck Flexion', imagePath: 'assets/exercise_images/neck/Lying-Weighted-Lateral-Neck-Flexion.gif', muscleGroup: 'Neck', fileName: 'Lying-Weighted-Lateral-Neck-Flexion.gif'),
      const ExerciseImage(name: 'Lying Weighted Neck Extension', imagePath: 'assets/exercise_images/neck/Lying-Weighted-Neck-Extension.gif', muscleGroup: 'Neck', fileName: 'Lying-Weighted-Neck-Extension.gif'),
      const ExerciseImage(name: 'Lying Weighted Neck Flexion', imagePath: 'assets/exercise_images/neck/Lying-Weighted-Neck-Flexion.gif', muscleGroup: 'Neck', fileName: 'Lying-Weighted-Neck-Flexion.gif'),
      const ExerciseImage(name: 'Neck Extension Stretching', imagePath: 'assets/exercise_images/neck/Neck-Extension-Stretching-360x360.png', muscleGroup: 'Neck', fileName: 'Neck-Extension-Stretching-360x360.png'),
      const ExerciseImage(name: 'Neck Flexion Stretching', imagePath: 'assets/exercise_images/neck/Neck-Flexion-Stretching-360x360.png', muscleGroup: 'Neck', fileName: 'Neck-Flexion-Stretching-360x360.png'),
      const ExerciseImage(name: 'Prone Cervical Extension', imagePath: 'assets/exercise_images/neck/Prone-Cervical-Extension.gif', muscleGroup: 'Neck', fileName: 'Prone-Cervical-Extension.gif'),
      const ExerciseImage(name: 'Rotating Neck Stretch', imagePath: 'assets/exercise_images/neck/Rotating-Neck-Stretch.gif', muscleGroup: 'Neck', fileName: 'Rotating-Neck-Stretch.gif'),
      const ExerciseImage(name: 'Side Neck Stretch', imagePath: 'assets/exercise_images/neck/Side-Neck-Stretch.gif', muscleGroup: 'Neck', fileName: 'Side-Neck-Stretch.gif'),
      const ExerciseImage(name: 'Side Push Neck Stretch', imagePath: 'assets/exercise_images/neck/Side-Push-Neck-Stretch.gif', muscleGroup: 'Neck', fileName: 'Side-Push-Neck-Stretch.gif'),
      const ExerciseImage(name: 'Sphinx Stretch', imagePath: 'assets/exercise_images/neck/Sphinx-Stretch.gif', muscleGroup: 'Neck', fileName: 'Sphinx-Stretch.gif'),
      const ExerciseImage(name: 'Superman Exercise', imagePath: 'assets/exercise_images/neck/Superman-exercise.gif', muscleGroup: 'Neck', fileName: 'Superman-exercise.gif'),
      const ExerciseImage(name: 'Weighted Lying Neck Extension', imagePath: 'assets/exercise_images/neck/Weighted-Lying-Neck-Extension.gif', muscleGroup: 'Neck', fileName: 'Weighted-Lying-Neck-Extension.gif'),
      const ExerciseImage(name: 'Weighted Lying Neck Flexion', imagePath: 'assets/exercise_images/neck/Weighted-Lying-Neck-Flexion.gif', muscleGroup: 'Neck', fileName: 'Weighted-Lying-Neck-Flexion.gif'),
      const ExerciseImage(name: 'Weighted Neck Harness Extension', imagePath: 'assets/exercise_images/neck/Weighted-Neck-Harness-Extension.gif', muscleGroup: 'Neck', fileName: 'Weighted-Neck-Harness-Extension.gif'),
      const ExerciseImage(name: 'Abdominal Stretch', imagePath: 'assets/exercise_images/neck/abdominal-stretch.gif', muscleGroup: 'Neck', fileName: 'abdominal-stretch.gif'),
    ];
  }

  // Trapezius exercises - all actual exercises from the folder
  static List<ExerciseImage> _getTrapeziusExercises() {
    return [
      const ExerciseImage(name: '45 Degree Incline Row', imagePath: 'assets/exercise_images/Trapezius/45-Degree-Incline-Row.gif', muscleGroup: 'Trapezius', fileName: '45-Degree-Incline-Row.gif'),
      const ExerciseImage(name: 'Band Pull Apart', imagePath: 'assets/exercise_images/Trapezius/Band-pull-apart.gif', muscleGroup: 'Trapezius', fileName: 'Band-pull-apart.gif'),
      const ExerciseImage(name: 'Barbell Rear Delt Raise', imagePath: 'assets/exercise_images/Trapezius/Barbell-Rear-Delt-Raise.gif', muscleGroup: 'Trapezius', fileName: 'Barbell-Rear-Delt-Raise.gif'),
      const ExerciseImage(name: 'Barbell Shrug', imagePath: 'assets/exercise_images/Trapezius/Barbell-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Barbell-Shrug.gif'),
      const ExerciseImage(name: 'Barbell Upright Row', imagePath: 'assets/exercise_images/Trapezius/Barbell-Upright-Row.gif', muscleGroup: 'Trapezius', fileName: 'Barbell-Upright-Row.gif'),
      const ExerciseImage(name: 'Behind The Back Barbell Shrug Reverse Barbell Shrug', imagePath: 'assets/exercise_images/Trapezius/Behind-The-Back-Barbell-Shrug-Reverse-Barbell-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Behind-The-Back-Barbell-Shrug-Reverse-Barbell-Shrug.gif'),
      const ExerciseImage(name: 'Bent Over Barbell Reverse Raise', imagePath: 'assets/exercise_images/Trapezius/Bent-Over-Barbell-Reverse-Raise.gif', muscleGroup: 'Trapezius', fileName: 'Bent-Over-Barbell-Reverse-Raise.gif'),
      const ExerciseImage(name: 'Bent Over Lateral Raise', imagePath: 'assets/exercise_images/Trapezius/Bent-Over-Lateral-Raise.gif', muscleGroup: 'Trapezius', fileName: 'Bent-Over-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Bent Over Rear Delt Fly Gymstick', imagePath: 'assets/exercise_images/Trapezius/Bent-Over-Rear-Delt-Fly-Gymstick.gif', muscleGroup: 'Trapezius', fileName: 'Bent-Over-Rear-Delt-Fly-Gymstick.gif'),
      const ExerciseImage(name: 'Bodyweight Military Press', imagePath: 'assets/exercise_images/Trapezius/Bodyweight-Military-Press.gif', muscleGroup: 'Trapezius', fileName: 'Bodyweight-Military-Press.gif'),
      const ExerciseImage(name: 'Cable Shrug', imagePath: 'assets/exercise_images/Trapezius/Cable-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Cable-Shrug.gif'),
      const ExerciseImage(name: 'Cable Upright Row', imagePath: 'assets/exercise_images/Trapezius/Cable-Upright-Row.gif', muscleGroup: 'Trapezius', fileName: 'Cable-Upright-Row.gif'),
      const ExerciseImage(name: 'Cross Cable Face Pull', imagePath: 'assets/exercise_images/Trapezius/Cross-Cable-Face-Pull.gif', muscleGroup: 'Trapezius', fileName: 'Cross-Cable-Face-Pull.gif'),
      const ExerciseImage(name: 'Dip Shrugs', imagePath: 'assets/exercise_images/Trapezius/Dip-Shrugs.gif', muscleGroup: 'Trapezius', fileName: 'Dip-Shrugs.gif'),
      const ExerciseImage(name: 'Dumbbell Decline Shrug', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Decline-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Decline-Shrug.gif'),
      const ExerciseImage(name: 'Dumbbell Incline Shrug', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Incline-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Incline-Shrug.gif'),
      const ExerciseImage(name: 'Dumbbell Incline T Raise', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Incline-T-Raise.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Incline-T-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Raise', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Raise.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Raise.gif'),
      const ExerciseImage(name: 'Dumbbell Reverse Fly', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Reverse-Fly.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Reverse-Fly.gif'),
      const ExerciseImage(name: 'Dumbbell Seated Gittleson Shrug', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Seated-Gittleson-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Seated-Gittleson-Shrug.gif'),
      const ExerciseImage(name: 'Dumbbell Shrug', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Shrug.gif'),
      const ExerciseImage(name: 'Dumbbell Upright Row', imagePath: 'assets/exercise_images/Trapezius/Dumbbell-Upright-Row.gif', muscleGroup: 'Trapezius', fileName: 'Dumbbell-Upright-Row.gif'),
      const ExerciseImage(name: 'Elbow Reverse Push Up', imagePath: 'assets/exercise_images/Trapezius/Elbow-Reverse-Push-Up.gif', muscleGroup: 'Trapezius', fileName: 'Elbow-Reverse-Push-Up.gif'),
      const ExerciseImage(name: 'Face Pull', imagePath: 'assets/exercise_images/Trapezius/Face-Pull.gif', muscleGroup: 'Trapezius', fileName: 'Face-Pull.gif'),
      const ExerciseImage(name: 'Foam Roller Upper Back', imagePath: 'assets/exercise_images/Trapezius/Foam-Roller-Upper-Back.gif', muscleGroup: 'Trapezius', fileName: 'Foam-Roller-Upper-Back.gif'),
      const ExerciseImage(name: 'Half Kneeling High Cable Row Rope', imagePath: 'assets/exercise_images/Trapezius/Half-Kneeling-High-Cable-Row-Rope.gif', muscleGroup: 'Trapezius', fileName: 'Half-Kneeling-High-Cable-Row-Rope.gif'),
      const ExerciseImage(name: 'Incline Dumbbell Y Raise', imagePath: 'assets/exercise_images/Trapezius/Incline-Dumbbell-Y-Raise.gif', muscleGroup: 'Trapezius', fileName: 'Incline-Dumbbell-Y-Raise.gif'),
      const ExerciseImage(name: 'Kneeling High Pulley Row', imagePath: 'assets/exercise_images/Trapezius/Kneeling-High-Pulley-Row.gif', muscleGroup: 'Trapezius', fileName: 'Kneeling-High-Pulley-Row.gif'),
      const ExerciseImage(name: 'Leaning Dumbbell Lateral Raise', imagePath: 'assets/exercise_images/Trapezius/Leaning-Dumbbell-Lateral-Raise.gif', muscleGroup: 'Trapezius', fileName: 'Leaning-Dumbbell-Lateral-Raise.gif'),
      const ExerciseImage(name: 'Levator Scapulae Stretch', imagePath: 'assets/exercise_images/Trapezius/Levator-Scapulae-Stretch.gif', muscleGroup: 'Trapezius', fileName: 'Levator-Scapulae-Stretch.gif'),
      const ExerciseImage(name: 'Machine Shrug', imagePath: 'assets/exercise_images/Trapezius/Machine-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Machine-Shrug.gif'),
      const ExerciseImage(name: 'Machine Upright Row', imagePath: 'assets/exercise_images/Trapezius/Machine-Upright-Row.gif', muscleGroup: 'Trapezius', fileName: 'Machine-Upright-Row.gif'),
      const ExerciseImage(name: 'Overhead Cable Shrug', imagePath: 'assets/exercise_images/Trapezius/Overhead-Cable-Shrug.gif', muscleGroup: 'Trapezius', fileName: 'Overhead-Cable-Shrug.gif'),
    ];
  }

  // Triceps exercises - all actual exercises from the folder
  static List<ExerciseImage> _getTricepsExercises() {
    return [
      const ExerciseImage(name: 'Alternating Lying Dumbbell Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Alternating-Lying-Dumbbell-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Alternating-Lying-Dumbbell-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Archer Push Up', imagePath: 'assets/exercise_images/Triceps/Archer-Push-Up.gif', muscleGroup: 'Triceps', fileName: 'Archer-Push-Up.gif'),
      const ExerciseImage(name: 'Assisted Triceps Dips', imagePath: 'assets/exercise_images/Triceps/Asisted-Triceps-Dips.gif', muscleGroup: 'Triceps', fileName: 'Asisted-Triceps-Dips.gif'),
      const ExerciseImage(name: 'Band Pushdown', imagePath: 'assets/exercise_images/Triceps/Band-Pushdown.gif', muscleGroup: 'Triceps', fileName: 'Band-Pushdown.gif'),
      const ExerciseImage(name: 'Band Skull Crusher', imagePath: 'assets/exercise_images/Triceps/Band-Skull-Crusher.gif', muscleGroup: 'Triceps', fileName: 'Band-Skull-Crusher.gif'),
      const ExerciseImage(name: 'Banded Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Banded-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Banded-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Barbell JM Press', imagePath: 'assets/exercise_images/Triceps/Barbell-JM-Press.gif', muscleGroup: 'Triceps', fileName: 'Barbell-JM-Press.gif'),
      const ExerciseImage(name: 'Barbell Lying Back Of The Head Tricep Extension', imagePath: 'assets/exercise_images/Triceps/Barbell-Lying-Back-of-the-Head-Tricep-Extension.gif', muscleGroup: 'Triceps', fileName: 'Barbell-Lying-Back-of-the-Head-Tricep-Extension.gif'),
      const ExerciseImage(name: 'Barbell One Arm Floor Press', imagePath: 'assets/exercise_images/Triceps/Barbell-One-Arm-Floor-Press.gif', muscleGroup: 'Triceps', fileName: 'Barbell-One-Arm-Floor-Press.gif'),
      const ExerciseImage(name: 'Barbell Reverse Close Grip Bench Press', imagePath: 'assets/exercise_images/Triceps/Barbell-Reverse-Close-grip-Bench-Press.gif', muscleGroup: 'Triceps', fileName: 'Barbell-Reverse-Close-grip-Bench-Press.gif'),
      const ExerciseImage(name: 'Barbell Reverse Grip Skullcrusher', imagePath: 'assets/exercise_images/Triceps/Barbell-Reverse-Grip-Skullcrusher-1.gif', muscleGroup: 'Triceps', fileName: 'Barbell-Reverse-Grip-Skullcrusher-1.gif'),
      const ExerciseImage(name: 'Barbell Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Barbell-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Barbell-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Bench Dips', imagePath: 'assets/exercise_images/Triceps/Bench-Dips.gif', muscleGroup: 'Triceps', fileName: 'Bench-Dips.gif'),
      const ExerciseImage(name: 'Bent Over Triceps Kickback', imagePath: 'assets/exercise_images/Triceps/Bent-Over-Triceps-Kickback.gif', muscleGroup: 'Triceps', fileName: 'Bent-Over-Triceps-Kickback.gif'),
      const ExerciseImage(name: 'Body Ups', imagePath: 'assets/exercise_images/Triceps/Body-Ups.gif', muscleGroup: 'Triceps', fileName: 'Body-Ups.gif'),
      const ExerciseImage(name: 'Bodyweight Skull Crushers', imagePath: 'assets/exercise_images/Triceps/Bodyweight-Skull-Crushers.gif', muscleGroup: 'Triceps', fileName: 'Bodyweight-Skull-Crushers.gif'),
      const ExerciseImage(name: 'Chair Dips', imagePath: 'assets/exercise_images/Triceps/CHAIR-DIPS.gif', muscleGroup: 'Triceps', fileName: 'CHAIR-DIPS.gif'),
      const ExerciseImage(name: 'Cable Concentration Extension On Knee', imagePath: 'assets/exercise_images/Triceps/Cable-Concentration-Extension-on-knee.gif', muscleGroup: 'Triceps', fileName: 'Cable-Concentration-Extension-on-knee.gif'),
      const ExerciseImage(name: 'Cable Crossover Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Cable-Crossover-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-Crossover-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Cable Incline Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Cable-Incline-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-Incline-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Cable Lying Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Cable-Lying-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-Lying-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Cable One Arm High Pulley Overhead Tricep Extension', imagePath: 'assets/exercise_images/Triceps/Cable-One-Arm-High-Pulley-Overhead-Tricep-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-One-Arm-High-Pulley-Overhead-Tricep-Extension.gif'),
      const ExerciseImage(name: 'Cable One Arm Overhead Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Cable-One-Arm-Overhead-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-One-Arm-Overhead-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Cable Rear Drive', imagePath: 'assets/exercise_images/Triceps/Cable-Rear-Drive.gif', muscleGroup: 'Triceps', fileName: 'Cable-Rear-Drive.gif'),
      const ExerciseImage(name: 'Cable Rope Lying On Floor Tricep Extension', imagePath: 'assets/exercise_images/Triceps/Cable-Rope-Lying-on-Floor-Tricep-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-Rope-Lying-on-Floor-Tricep-Extension.gif'),
      const ExerciseImage(name: 'Cable Rope Overhead Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Cable-Rope-Overhead-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-Rope-Overhead-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Cable Side Triceps Extension', imagePath: 'assets/exercise_images/Triceps/Cable-Side-Triceps-Extension.gif', muscleGroup: 'Triceps', fileName: 'Cable-Side-Triceps-Extension.gif'),
      const ExerciseImage(name: 'Cable Triceps Pushdown', imagePath: 'assets/exercise_images/Triceps/Cable-Triceps-Pushdown.gif', muscleGroup: 'Triceps', fileName: 'Cable-Triceps-Pushdown.gif'),
    ];
  }

  // Helper method to get directory name from muscle group
  static String _getDirectoryName(String muscleGroup) {
    final directoryMap = {
      'Abs or Core': 'abs_core',
      'Back & Wings': 'back',
      'Biceps': 'biceps',
      'Calf': 'calf',
      'Cardio': 'cardio',
      'Chest': 'chest',
      'Erector Spinae': 'erector_spinae',
      'Forearm': 'forearm',
      'Full Body': 'full_body',
      'Hips': 'hips',
      'Leg': 'legs',
      'Neck': 'neck',
      'Shoulder': 'shoulders',
      'Trapezius': 'trapezius',
      'Triceps': 'triceps',
    };
    
    return directoryMap[muscleGroup] ?? muscleGroup.toLowerCase().replaceAll(' ', '_');
  }

  // Helper method to get muscle group enum value
  static String _getMuscleGroupEnumValue(String muscleGroup) {
    final enumMap = {
      'Abs or Core': 'abs_core',
      'Back & Wings': 'back',
      'Biceps': 'biceps',
      'Calf': 'calf',
      'Cardio': 'cardio',
      'Chest': 'chest',
      'Erector Spinae': 'erector_spinae',
      'Forearm': 'forearm',
      'Full Body': 'full_body',
      'Hips': 'hips',
      'Leg': 'legs',
      'Neck': 'neck',
      'Shoulder': 'shoulders',
      'Trapezius': 'trapezius',
      'Triceps': 'triceps',
    };
    
    return enumMap[muscleGroup] ?? muscleGroup.toLowerCase().replaceAll(' ', '_');
  }

  // Helper method to get default image path
  static String? _getDefaultImagePath(String directoryName) {
    final imageMap = {
      'abs_core': 'assets/img/what_1.png',
      'back': 'assets/img/what_2.png',
      'biceps': 'assets/img/what_1.png',
      'calf': 'assets/img/what_2.png',
      'cardio': 'assets/img/what_1.png',
      'chest': 'assets/img/what_2.png',
      'erector_spinae': 'assets/img/what_1.png',
      'forearm': 'assets/img/what_1.png',
      'full_body': 'assets/img/what_2.png',
      'hips': 'assets/img/what_2.png',
      'legs': 'assets/img/what_2.png',
      'neck': 'assets/img/what_1.png',
      'shoulders': 'assets/img/what_1.png',
      'trapezius': 'assets/img/what_2.png',
      'triceps': 'assets/img/what_1.png',
    };
    
    return imageMap[directoryName] ?? 'assets/img/what_1.png';
  }
}

class MuscleGroupService {
  static Future<List<MuscleGroupModel>> getMuscleGroups() async {
    return await ExerciseImageManager.getMuscleGroups();
  }

  static Future<List<ExerciseModel>> getExercisesForMuscleGroup(String directoryName) async {
    // Get all exercises for the specified muscle group directory
    final allExercises = [
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Calf', 'Calf'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Forearm', 'Forearm'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Hips', 'Hips'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Leg', 'Leg'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Shoulder', 'Shoulder'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Abs or core', 'Abs or Core'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/back or wing', 'Back & Wings'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Biceps', 'Biceps'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Cardio', 'Cardio'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/chest', 'Chest'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Erector spinae', 'Erector Spinae'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Full Body', 'Full Body'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/neck', 'Neck'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Trapezius', 'Trapezius'),
      ...await ExerciseImageManager._getExercisesForFolder('assets/exercise_images/Triceps', 'Triceps'),
    ];

    // Filter exercises by directory name
    final filteredExercises = allExercises.where((exercise) {
      final exerciseDirectoryName = _getDirectoryNameFromMuscleGroup(exercise.muscleGroup);
      return exerciseDirectoryName == directoryName;
    }).toList();

    // Convert ExerciseImage to ExerciseModel
    return filteredExercises.map((exerciseImage) {
      return ExerciseModel.fromAssetPath(exerciseImage.imagePath, _getMuscleGroupEnumValue(exerciseImage.muscleGroup));
    }).toList();
  }

  static String _getDirectoryNameFromMuscleGroup(String muscleGroup) {
    final directoryMap = {
      'Abs or Core': 'abs_core',
      'Back & Wings': 'back',
      'Biceps': 'biceps',
      'Calf': 'calf',
      'Cardio': 'cardio',
      'Chest': 'chest',
      'Erector Spinae': 'erector_spinae',
      'Forearm': 'forearm',
      'Full Body': 'full_body',
      'Hips': 'hips',
      'Leg': 'legs',
      'Neck': 'neck',
      'Shoulder': 'shoulders',
      'Trapezius': 'trapezius',
      'Triceps': 'triceps',
    };
    
    return directoryMap[muscleGroup] ?? muscleGroup.toLowerCase();
  }

  static String _getMuscleGroupEnumValue(String muscleGroup) {
    final enumMap = {
      'Abs or Core': 'abs_core',
      'Back & Wings': 'back',
      'Biceps': 'biceps',
      'Calf': 'calf',
      'Cardio': 'cardio',
      'Chest': 'chest',
      'Erector Spinae': 'erector_spinae',
      'Forearm': 'forearm',
      'Full Body': 'full_body',
      'Hips': 'hips',
      'Leg': 'legs',
      'Neck': 'neck',
      'Shoulder': 'shoulders',
      'Trapezius': 'trapezius',
      'Triceps': 'triceps',
    };
    
    return enumMap[muscleGroup] ?? muscleGroup.toLowerCase().replaceAll(' ', '_');
  }
}