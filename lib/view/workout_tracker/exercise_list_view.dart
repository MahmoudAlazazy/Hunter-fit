import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/core/models/muscle_group_model.dart';
import 'package:fitness/core/models/exercise_model.dart';
import 'package:fitness/core/services/muscle_group_service.dart';
import 'package:flutter/material.dart';

import 'exercise_detail_view.dart';

class ExerciseListView extends StatefulWidget {
  final MuscleGroupModel muscleGroup;

  const ExerciseListView({super.key, required this.muscleGroup});

  @override
  State<ExerciseListView> createState() => _ExerciseListViewState();
}

class _ExerciseListViewState extends State<ExerciseListView> {
  List<ExerciseModel> exercises = [];
  bool isLoading = true;
  String? selectedDifficulty;
  List<String> difficultyOptions = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exerciseList = await MuscleGroupService.getExercisesForMuscleGroup(
        widget.muscleGroup.directoryName,
      );
      setState(() {
        exercises = exerciseList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading exercises: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ExerciseModel> get filteredExercises {
    if (selectedDifficulty == null || selectedDifficulty == 'All') {
      return exercises;
    }
    
    final difficultyMap = {
      'Beginner': ExerciseDifficulty.beginner,
      'Intermediate': ExerciseDifficulty.intermediate,
      'Advanced': ExerciseDifficulty.advanced,
    };
    
    final targetDifficulty = difficultyMap[selectedDifficulty];
    return exercises.where((exercise) => exercise.difficulty == targetDifficulty).toList();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
        title: Text(
          widget.muscleGroup.displayName,
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TColor.primaryColor1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading exercises...",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: TColor.lightGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No exercises found",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Try selecting a different muscle group",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              TColor.primaryColor2.withValues(alpha: 0.3),
                              TColor.primaryColor1.withValues(alpha: 0.3)
                            ]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.muscleGroup.displayName,
                                      style: TextStyle(
                                          color: TColor.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${exercises.length} Exercises Available",
                                      style: TextStyle(
                                        color: TColor.gray,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  widget.muscleGroup.imagePath ?? "assets/img/what_1.png",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Exercises",
                              style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: TColor.lightGray.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                value: selectedDifficulty ?? 'All',
                                underline: const SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, color: TColor.gray, size: 16),
                                style: TextStyle(color: TColor.black, fontSize: 12),
                                items: difficultyOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedDifficulty = newValue;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        filteredExercises.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 40),
                                    Icon(
                                      Icons.fitness_center,
                                      size: 64,
                                      color: TColor.lightGray,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No exercises found",
                                      style: TextStyle(
                                        color: TColor.gray,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Try selecting a different difficulty level",
                                      style: TextStyle(
                                        color: TColor.gray,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: filteredExercises.length,
                                itemBuilder: (context, index) {
                                  var exercise = filteredExercises[index];
                                  return _buildExerciseCard(exercise, index, media);
                                },
                              ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: RoundButton(
                            title: "Create Workout",
                            onPressed: () {
                              _createWorkoutFromExercises();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, int index, Size media) {
    return Tooltip(
      message: exercise.description ?? 'Exercise for ${widget.muscleGroup.displayName}',
      child: InkWell(
        onTap: () {
          _navigateToExerciseDetail(exercise, index);
        },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getDifficultyColor(exercise.difficulty).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: exercise.gifPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        exercise.gifPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: ${exercise.gifPath} - $error');
                          return Container(
                            color: _getDifficultyColor(exercise.difficulty).withValues(alpha: 0.1),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    color: _getDifficultyColor(exercise.difficulty),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                        color: _getDifficultyColor(exercise.difficulty),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: _getDifficultyColor(exercise.difficulty).withValues(alpha: 0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: _getDifficultyColor(exercise.difficulty),
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${index + 1}",
                              style: TextStyle(
                                  color: _getDifficultyColor(exercise.difficulty),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.displayName,
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(exercise.difficulty).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getDifficultyText(exercise.difficulty),
                          style: TextStyle(
                            color: _getDifficultyColor(exercise.difficulty),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (exercise.equipment != null && exercise.equipment != 'None (Bodyweight)')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: TColor.gray.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            exercise.equipment!,
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (exercise.sets != null)
                        Text(
                          "${exercise.sets} sets",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 11,
                          ),
                        ),
                      if (exercise.sets != null && exercise.reps != null)
                        Text(
                          " × ",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 11,
                          ),
                        ),
                      if (exercise.reps != null)
                        Text(
                          "${exercise.reps} reps",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 11,
                          ),
                        ),
                      if (exercise.durationSeconds != null)
                        Text(
                          "${exercise.durationSeconds}s",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: TColor.gray,
              size: 16,
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _navigateToExerciseDetail(ExerciseModel exercise, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailView(
          exercise: exercise,
          muscleGroupName: widget.muscleGroup.displayName,
        ),
      ),
    );
  }



  Color _getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return Colors.green;
      case ExerciseDifficulty.intermediate:
        return Colors.orange;
      case ExerciseDifficulty.advanced:
        return Colors.red;
    }
  }

  String _getDifficultyText(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }

  void _createWorkoutFromExercises() {
    final workoutObj = {
      'title': '${widget.muscleGroup.displayName} Workout',
      'muscle_group': widget.muscleGroup.displayName,
      'exercises': exercises,
      'exercise_count': exercises.length,
      'duration': '${exercises.length * 2} mins',
    };

    // Navigate to workout creation or schedule view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout created for ${widget.muscleGroup.displayName}'),
        backgroundColor: TColor.primaryColor1,
      ),
    );
  }
}