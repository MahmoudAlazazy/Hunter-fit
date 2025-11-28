import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../core/models/workout_group_model.dart';
import '../../core/services/workout_group_service.dart';
import 'workout_group_detail_view.dart';
import 'create_workout_group_dialog.dart';

class AllWorkoutGroupsView extends StatefulWidget {
  const AllWorkoutGroupsView({super.key});

  @override
  State<AllWorkoutGroupsView> createState() => _AllWorkoutGroupsViewState();
}

class _AllWorkoutGroupsViewState extends State<AllWorkoutGroupsView> {
  List<WorkoutGroupModel> workoutGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutGroups();
  }

  Future<void> _loadWorkoutGroups() async {
    try {
      final workoutGroupService = WorkoutGroupService();
      final groups = await workoutGroupService.getWorkoutGroups();
      
      if (mounted) {
        setState(() {
          workoutGroups = groups;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading workout groups: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _showCreateGroupDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateWorkoutGroupDialog(),
    );

    if (result == true) {
      _loadWorkoutGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            "assets/img/black_btn.png",
            width: 25,
            height: 25,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          "My Workout Groups",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCreateGroupDialog,
            icon: Icon(
              Icons.add,
              color: TColor.primaryColor1,
              size: 28,
            ),
          ),
        ],
      ),
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
                    "Loading workout groups...",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : workoutGroups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: TColor.lightGray,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No workout groups yet",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create your first workout group",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _showCreateGroupDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primaryColor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Create Group",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: workoutGroups.length,
                  itemBuilder: (context, index) {
                    final group = workoutGroups[index];
                    return _buildWorkoutGroupCard(group, media);
                  },
                ),
    );
  }

  Widget _buildWorkoutGroupCard(WorkoutGroupModel group, Size media) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutGroupDetailView(workoutGroup: group),
              ),
            ).then((_) {
              // Refresh workout groups when returning from detail view
              _loadWorkoutGroups();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Progress Circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: group.completionProgress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 4,
                        ),
                      ),
                      Text(
                        "${(group.completionProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (group.description != null && group.description!.isNotEmpty)
                        Text(
                          group.description!,
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 8,
                          width: double.maxFinite,
                          color: TColor.lightGray,
                          child: Row(
                            children: [
                              Expanded(
                                flex: (group.completionProgress * 100).toInt(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: TColor.primaryG),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: ((1 - group.completionProgress) * 100).toInt(),
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${group.completedExercises} of ${group.totalExercises} exercises",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Created: ${_formatDate(group.createdDate)}",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: TColor.gray,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}