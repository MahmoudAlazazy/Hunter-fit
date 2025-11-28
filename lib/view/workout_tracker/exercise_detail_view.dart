import 'package:fitness/core/models/exercise_model.dart';
import 'package:fitness/core/models/workout_group_model.dart';
import 'package:fitness/core/services/workout_group_service.dart';
import 'package:fitness/view/workout_tracker/select_workout_group_dialog.dart';
import 'package:fitness/view/workout_tracker/create_workout_group_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:readmore/readmore.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';

class ExerciseDetailView extends StatefulWidget {
  final ExerciseModel exercise;
  final String? muscleGroupName;

  const ExerciseDetailView({
    super.key,
    required this.exercise,
    this.muscleGroupName,
  });

  @override
  State<ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<ExerciseDetailView> {
  int selectedSets = 3;
  int selectedReps = 12;
  bool isLoading = false;
  
  late FixedExtentScrollController _setsController;
  late FixedExtentScrollController _repsController;
  
  @override
  void initState() {
    super.initState();
    _setsController = FixedExtentScrollController(initialItem: selectedSets - 1);
    _repsController = FixedExtentScrollController(initialItem: selectedReps - 1);
  }
  
  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
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
        title: Text(
          widget.exercise.displayName,
          style: TextStyle(
              color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (widget.exercise.gifPath != null)
            IconButton(
              onPressed: () {
                _showFullImage(context);
              },
              icon: Icon(Icons.zoom_in, color: TColor.primaryColor1),
            ),
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Image
            if (widget.exercise.gifPath != null)
              Container(
                width: media.width,
                height: media.width * 0.44,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: TColor.primaryColor1,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    widget.exercise.gifPath!,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    cacheWidth: (media.width * 0.35 * MediaQuery.of(context).devicePixelRatio).round(),
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: TColor.lightGray,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 50,
                                color: TColor.primaryColor1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.exercise.displayName,
                                style: TextStyle(
                                  color: TColor.primaryColor1,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: media.width,
                height: media.width * 0.35,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: TColor.primaryColor1,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: TColor.primaryColor1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.exercise.displayName,
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Difficulty",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _getDifficultyText(),
                                style: TextStyle(
                                  color: _getDifficultyColor(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: TColor.primaryColor1.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Equipment",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.exercise.equipment ?? "None",
                                style: TextStyle(
                                  color: TColor.primaryColor1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: TColor.secondaryColor1.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Muscle Group",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.muscleGroupName ?? widget.exercise.muscleGroup,
                                style: TextStyle(
                                  color: TColor.secondaryColor1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "Description",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ReadMoreText(
                    widget.exercise.description ?? "No description available.",
                    trimLines: 3,
                    colorClickableText: TColor.primaryColor1,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Show less',
                    moreStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TColor.primaryColor1,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TColor.primaryColor1,
                    ),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Target Muscles
                  Text(
                    "Target Muscles",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.exercise.targetMuscles ?? "Not specified",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Instructions
                  Text(
                    "Instructions",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.exercise.instructions ?? "Follow proper form and technique.",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tips
                  Text(
                    "Tips",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.exercise.tips ?? "Focus on proper form and controlled movements.",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Exercise Configuration
                  Text(
                    "Exercise Configuration",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sets and Reps Configuration
                  Text(
                    "Custom Repetitions",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sets",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: TColor.lightGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CupertinoPicker.builder(
                                scrollController: _setsController,
                                itemExtent: 40,
                                selectionOverlay: Container(
                                  width: double.maxFinite,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: TColor.gray.withValues(alpha: 0.2), width: 1),
                                      bottom: BorderSide(color: TColor.gray.withValues(alpha: 0.2), width: 1),
                                    ),
                                  ),
                                ),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedSets = index + 1;
                                  });
                                },
                                childCount: 20,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        " ${index + 1} ",
                                        style: TextStyle(
                                          color: TColor.gray,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        " sets",
                                        style: TextStyle(
                                          color: TColor.gray,
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reps",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: TColor.lightGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CupertinoPicker.builder(
                                scrollController: _repsController,
                                itemExtent: 40,
                                selectionOverlay: Container(
                                  width: double.maxFinite,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: TColor.gray.withValues(alpha: 0.2), width: 1),
                                      bottom: BorderSide(color: TColor.gray.withValues(alpha: 0.2), width: 1),
                                    ),
                                  ),
                                ),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedReps = index + 1;
                                  });
                                },
                                childCount: 50,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        " ${index + 1} ",
                                        style: TextStyle(
                                          color: TColor.gray,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        " reps",
                                        style: TextStyle(
                                          color: TColor.gray,
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: RoundButton(
                      title: isLoading ? "Saving..." : "Save to Workout Group",
                      onPressed: isLoading ? null : () => _saveToWorkoutGroup(),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.exercise.difficulty) {
      case ExerciseDifficulty.beginner:
        return Colors.green;
      case ExerciseDifficulty.intermediate:
        return Colors.orange;
      case ExerciseDifficulty.advanced:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getDifficultyText() {
    switch (widget.exercise.difficulty) {
      case ExerciseDifficulty.beginner:
        return "Beginner";
      case ExerciseDifficulty.intermediate:
        return "Intermediate";
      case ExerciseDifficulty.advanced:
        return "Advanced";
      default:
        return "Unknown";
    }
  }

  void _showFullImage(BuildContext context) {
    if (widget.exercise.gifPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.asset(
                  widget.exercise.gifPath!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _saveToWorkoutGroup() {
    _performSaveToWorkoutGroup();
  }

  Future<void> _performSaveToWorkoutGroup() async {
    setState(() {
      isLoading = true;
    });

    try {
      final workoutGroupService = WorkoutGroupService();
      final workoutGroups = await workoutGroupService.getWorkoutGroups();

      if (workoutGroups.isEmpty) {
        // No workout groups exist, ask user to create a new one
        final groupData = await showDialog<Map<String, String>>(
          context: context,
          builder: (context) => CreateWorkoutGroupDialog(
            suggestedName: "${widget.exercise.displayName} Group",
          ),
        );

        if (groupData == null) {
          // User cancelled the dialog
          setState(() {
            isLoading = false;
          });
          return;
        }

        final newGroup = WorkoutGroupModel(
          id: workoutGroupService.generateGroupId(),
          name: groupData['name'] ?? "My Workout Group",
          description: groupData['description'] ?? "Custom workout group",
          imagePath: widget.exercise.gifPath,
          exercises: [],
          createdDate: DateTime.now(),
        );

        try {
          // Save the new group first
          await workoutGroupService.saveWorkoutGroup(newGroup);
          
          // Verify the group was saved
          final savedGroup = await workoutGroupService.getWorkoutGroup(newGroup.id);
          if (savedGroup == null) {
            throw Exception('Failed to save workout group');
          }

          // Then add the exercise to the newly created group
          await workoutGroupService.addExerciseToGroup(
            newGroup.id,
            widget.exercise,
            selectedSets,
            selectedReps,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Exercise saved to ${newGroup.name}!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          print('Error creating new workout group: $e');
          rethrow;
        }
      } else {
        // Show dialog to select existing group or create new one
        if (mounted) {
          final selectedGroup = await showDialog<WorkoutGroupModel>(
            context: context,
            builder: (context) => SelectWorkoutGroupDialog(
              workoutGroups: workoutGroups,
            ),
          );

          if (selectedGroup != null) {
            // Verify the selected group still exists
            final existingGroup = await workoutGroupService.getWorkoutGroup(selectedGroup.id);
            if (existingGroup == null) {
              throw Exception('Selected workout group no longer exists');
            }

            await workoutGroupService.addExerciseToGroup(
              selectedGroup.id,
              widget.exercise,
              selectedSets,
              selectedReps,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exercise saved to ${selectedGroup.name}!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error saving exercise';
        if (e.toString().contains('Workout group not found')) {
          errorMessage = 'Workout group not found. Please try again.';
        } else {
          errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}