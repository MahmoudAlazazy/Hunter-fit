import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../core/models/workout_group_model.dart';
import '../../core/services/workout_group_service.dart';

class CreateWorkoutGroupDialog extends StatefulWidget {
  final String? suggestedName;
  
  const CreateWorkoutGroupDialog({
    super.key,
    this.suggestedName,
  });

  @override
  State<CreateWorkoutGroupDialog> createState() => _CreateWorkoutGroupDialogState();
}

class _CreateWorkoutGroupDialogState extends State<CreateWorkoutGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.suggestedName != null) {
      _nameController.text = widget.suggestedName!;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              "Create Workout Group",
              style: TextStyle(
                color: TColor.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Group Name",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter group name",
                hintStyle: TextStyle(
                  color: TColor.gray.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.gray.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.gray.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.primaryColor1, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Description (Optional)",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Enter group description",
                hintStyle: TextStyle(
                  color: TColor.gray.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.gray.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.gray.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.primaryColor1, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: RoundButton(
                    title: "Cancel",
                    type: RoundButtonType.text,
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: RoundButton(
                    title: "Create",
                    onPressed: () async {
                      if (_nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a group name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      try {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        
                        // Create a new WorkoutGroupModel with proper ID
                        final newGroup = WorkoutGroupModel(
                          id: WorkoutGroupService().generateGroupId(),
                          name: _nameController.text.trim(),
                          description: _descriptionController.text.trim().isEmpty 
                              ? null 
                              : _descriptionController.text.trim(),
                          exercises: [], // Start with empty exercises list
                          createdDate: DateTime.now(),
                          lastModifiedDate: DateTime.now(),
                        );
                        
                        // Save to database
                        await WorkoutGroupService().saveWorkoutGroup(newGroup);
                        
                        // Close loading indicator
                        Navigator.pop(context);
                        
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Workout group "${newGroup.name}" created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        
                        // Close dialog and return the new group
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            Navigator.pop(context, newGroup);
                          }
                        });
                      } catch (e) {
                        // Close loading indicator
                        Navigator.pop(context);
                        
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating workout group: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}