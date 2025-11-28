import 'package:fitness/core/models/exercise_model.dart';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../core/models/workout_group_model.dart';
import '../../core/services/workout_group_service.dart';
import 'exercise_detail_view.dart';
import 'edit_workout_group_dialog.dart';

class WorkoutGroupDetailView extends StatefulWidget {
  final WorkoutGroupModel workoutGroup;

  const WorkoutGroupDetailView({
    super.key,
    required this.workoutGroup,
  });

  @override
  State<WorkoutGroupDetailView> createState() => _WorkoutGroupDetailViewState();
}

class _WorkoutGroupDetailViewState extends State<WorkoutGroupDetailView> {
  late WorkoutGroupModel _workoutGroup;

  @override
  void initState() {
    super.initState();
    _workoutGroup = widget.workoutGroup;
    _loadWorkoutGroup();
  }

  Future<void> _loadWorkoutGroup() async {
    try {
      final workoutGroupService = WorkoutGroupService();
      final updatedGroup = await workoutGroupService.getWorkoutGroup(_workoutGroup.id);
      
      if (updatedGroup != null && mounted) {
        setState(() {
          _workoutGroup = updatedGroup;
        });
      }
    } catch (e) {
      print('Error loading workout group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    bool isTablet = media.width > 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: TColor.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _workoutGroup.name,
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: TColor.black, size: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _editWorkoutGroup();
              } else if (value == 'delete') {
                _deleteWorkoutGroup();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: TColor.gray),
                    const SizedBox(width: 10),
                    const Text("Edit", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text("Delete", style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  margin: EdgeInsets.all(isTablet ? 24 : 16),
                  padding: EdgeInsets.all(isTablet ? 28 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            width: isTablet ? 100 : 80,
                            height: isTablet ? 100 : 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _workoutGroup.imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      _workoutGroup.imagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.fitness_center,
                                          size: isTablet ? 36 : 32,
                                          color: TColor.gray.withValues(alpha: 0.4),
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.fitness_center,
                                    size: isTablet ? 36 : 32,
                                    color: TColor.gray.withValues(alpha: 0.4),
                                  ),
                          ),
                          
                          SizedBox(width: isTablet ? 20 : 16),
                          
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _workoutGroup.name,
                                  style: TextStyle(
                                    fontSize: isTablet ? 24 : 20,
                                    fontWeight: FontWeight.w600,
                                    color: TColor.black,
                                    height: 1.2,
                                  ),
                                ),
                                if (_workoutGroup.description != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _workoutGroup.description!,
                                    style: TextStyle(
                                      fontSize: isTablet ? 15 : 13,
                                      color: TColor.gray,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                SizedBox(height: isTablet ? 14 : 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildInfoChip(
                                      icon: Icons.format_list_bulleted,
                                      label: "${_workoutGroup.totalExercises} exercises",
                                      isTablet: isTablet,
                                    ),
                                    _buildInfoChip(
                                      icon: Icons.check_circle_outline,
                                      label: "${(completionProgress * 100).toInt()}%",
                                      color: completionProgress > 0 ? Colors.green : null,
                                      isTablet: isTablet,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isTablet ? 24 : 20),
                      
                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Progress",
                                style: TextStyle(
                                  fontSize: isTablet ? 15 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: TColor.gray,
                                ),
                              ),
                              Text(
                                "${(completionProgress * 100).toInt()}%",
                                style: TextStyle(
                                  fontSize: isTablet ? 15 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: TColor.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: completionProgress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF0F0F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                TColor.primaryColor1.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  label: "Completed",
                                  value: "${_workoutGroup.completedExercises}",
                                  color: Colors.green.withValues(alpha: 0.85),
                                  isTablet: isTablet,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  label: "Remaining",
                                  value: "${_workoutGroup.totalExercises - _workoutGroup.completedExercises}",
                                  color: Colors.orange.withValues(alpha: 0.85),
                                  isTablet: isTablet,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Section Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 24 : 16,
                    isTablet ? 8 : 4,
                    isTablet ? 24 : 16,
                    isTablet ? 16 : 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Exercises",
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          color: TColor.black,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _startWorkout,
                        icon: Icon(
                          Icons.play_arrow_rounded,
                          size: isTablet ? 22 : 20,
                        ),
                        label: Text(
                          "Start",
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: TColor.primaryColor1,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 10 : 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Exercises List
                if (_workoutGroup.exercises.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 60 : 40,
                      horizontal: isTablet ? 24 : 16,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isTablet ? 28 : 24),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              size: isTablet ? 56 : 48,
                              color: TColor.gray.withValues(alpha: 0.3),
                            ),
                          ),
                          SizedBox(height: isTablet ? 20 : 16),
                          Text(
                            "No exercises yet",
                            style: TextStyle(
                              fontSize: isTablet ? 17 : 15,
                              fontWeight: FontWeight.w600,
                              color: TColor.gray,
                            ),
                          ),
                          SizedBox(height: isTablet ? 8 : 6),
                          Text(
                            "Add exercises to get started",
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: TColor.gray.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                    ),
                    itemCount: _workoutGroup.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _workoutGroup.exercises[index];
                      return _buildExerciseCard(exercise, index, isTablet);
                    },
                  ),

                SizedBox(height: isTablet ? 40 : 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10,
        vertical: isTablet ? 7 : 6,
      ),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.08) ?? const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isTablet ? 16 : 14,
            color: color ?? TColor.gray.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w500,
              color: color ?? TColor.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required bool isTablet,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isTablet ? 8 : 6,
          height: isTablet ? 8 : 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: TColor.black,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: TColor.gray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    WorkoutGroupExercise workoutExercise,
    int index,
    bool isTablet,
  ) {
    final exercise = workoutExercise.exercise;
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToExerciseDetail(exercise),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 18 : 14),
            child: Row(
              children: [
                // Image
                Container(
                  width: isTablet ? 70 : 60,
                  height: isTablet ? 70 : 60,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(exercise.difficulty)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      if (exercise.gifPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            exercise.gifPath!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  color: _getDifficultyColor(exercise.difficulty)
                                      .withValues(alpha: 0.4),
                                  size: isTablet ? 28 : 24,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Center(
                          child: Icon(
                            Icons.fitness_center,
                            color: _getDifficultyColor(exercise.difficulty)
                                .withValues(alpha: 0.4),
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                      // Index
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 7,
                            vertical: isTablet ? 4 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.w600,
                              color: TColor.black,
                            ),
                          ),
                        ),
                      ),
                      // Completion Badge
                      if (workoutExercise.isCompleted)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(width: isTablet ? 16 : 12),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.displayName,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: workoutExercise.isCompleted 
                              ? TColor.gray.withValues(alpha: 0.6)
                              : TColor.black,
                          decoration: workoutExercise.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isTablet ? 8 : 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildBadge(
                            _getDifficultyText(exercise.difficulty),
                            _getDifficultyColor(exercise.difficulty),
                            isTablet,
                          ),
                          if (exercise.equipment != null && 
                              exercise.equipment != 'None (Bodyweight)')
                            _buildBadge(
                              exercise.equipment!,
                              TColor.gray.withValues(alpha: 0.6),
                              isTablet,
                            ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 8 : 6),
                      Row(
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: isTablet ? 15 : 13,
                            color: TColor.gray.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${workoutExercise.sets} × ${workoutExercise.reps}",
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              color: TColor.gray,
                            ),
                          ),
                          if (workoutExercise.restSeconds != null) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.timer_outlined,
                              size: isTablet ? 15 : 13,
                              color: TColor.gray.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${workoutExercise.restSeconds}s",
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                color: TColor.gray,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: isTablet ? 12 : 8),
                
                // Action
                IconButton(
                  onPressed: () => _toggleExerciseCompletion(workoutExercise),
                  icon: Icon(
                    workoutExercise.isCompleted 
                        ? Icons.refresh_rounded 
                        : Icons.check_circle_outline,
                    color: workoutExercise.isCompleted 
                        ? Colors.orange.withValues(alpha: 0.85)
                        : Colors.green.withValues(alpha: 0.85),
                    size: isTablet ? 26 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 9 : 8,
        vertical: isTablet ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTablet ? 11 : 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return const Color(0xFF4CAF50);
      case ExerciseDifficulty.intermediate:
        return const Color(0xFFFF9800);
      case ExerciseDifficulty.advanced:
        return const Color(0xFFF44336);
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

  double get completionProgress {
    return _workoutGroup.totalExercises > 0 
        ? _workoutGroup.completedExercises / _workoutGroup.totalExercises 
        : 0.0;
  }

  void _navigateToExerciseDetail(ExerciseModel exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailView(
          exercise: exercise,
          muscleGroupName: null,
        ),
      ),
    ).then((_) => _loadWorkoutGroup());
  }

  Future<void> _toggleExerciseCompletion(WorkoutGroupExercise workoutExercise) async {
    try {
      final workoutGroupService = WorkoutGroupService();
      await workoutGroupService.updateExerciseCompletion(
        _workoutGroup.id,
        workoutExercise.exercise.id,
        !workoutExercise.isCompleted,
      );

      await _loadWorkoutGroup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              workoutExercise.isCompleted 
                  ? "Marked as incomplete" 
                  : "Exercise completed!",
            ),
            backgroundColor: workoutExercise.isCompleted 
                ? Colors.orange.withValues(alpha: 0.9)
                : Colors.green.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  void _startWorkout() {
    if (_workoutGroup.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No exercises in this group"),
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final firstExercise = _workoutGroup.exercises.first;
    _navigateToExerciseDetail(firstExercise.exercise);
  }

  void _editWorkoutGroup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditWorkoutGroupDialog(workoutGroup: _workoutGroup),
    );

    if (result == true) {
      await _loadWorkoutGroup();
    }
  }

  void _deleteWorkoutGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Workout Group"),
        content: Text(
          "Are you sure you want to delete '${_workoutGroup.name}'? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete() async {
    try {
      final workoutGroupService = WorkoutGroupService();
      await workoutGroupService.deleteWorkoutGroup(_workoutGroup.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Workout group deleted"),
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }
}