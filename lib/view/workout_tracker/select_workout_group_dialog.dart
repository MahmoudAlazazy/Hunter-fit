import 'package:fitness/view/workout_tracker/create_workout_group_dialog.dart';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../core/models/workout_group_model.dart';

class SelectWorkoutGroupDialog extends StatefulWidget {
  final List<WorkoutGroupModel> workoutGroups;

  const SelectWorkoutGroupDialog({
    super.key,
    required this.workoutGroups,
  });

  @override
  State<SelectWorkoutGroupDialog> createState() => _SelectWorkoutGroupDialogState();
}

class _SelectWorkoutGroupDialogState extends State<SelectWorkoutGroupDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Select Workout Group",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    });
                  },
                  icon: Icon(Icons.close, color: TColor.gray),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            if (widget.workoutGroups.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: TColor.gray,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No workout groups found",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: widget.workoutGroups.length,
                      itemBuilder: (context, index) {
                        final group = widget.workoutGroups[index];
                        return _buildWorkoutGroupCard(group);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Create New Group Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _createNewGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primaryColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Create New Group",
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutGroupCard(WorkoutGroupModel group) {
    return InkWell(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context, group);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColor.lightGray,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: TColor.primaryColor1.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Group Image or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: group.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        group.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fitness_center,
                            size: 30,
                            color: TColor.primaryColor1,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.fitness_center,
                      size: 30,
                      color: TColor.primaryColor1,
                    ),
            ),
            
            const SizedBox(width: 15),
            
            // Group Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (group.description != null)
                    Text(
                      group.description!,
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: TColor.gray,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "${group.totalExercises} exercises",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: group.completionProgress > 0 
                                  ? Colors.green 
                                  : TColor.gray,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "${(group.completionProgress * 100).toInt()}% complete",
                                style: TextStyle(
                                  color: group.completionProgress > 0 
                                      ? Colors.green 
                                      : TColor.gray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: TColor.gray,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewGroup() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog<WorkoutGroupModel>(
          context: context,
          builder: (context) => const CreateWorkoutGroupDialog(),
        ).then((newGroup) {
          if (newGroup != null && mounted) {
            Navigator.pop(context, newGroup);
          }
        });
      }
    });
  }
}