import 'package:flutter/material.dart';
import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common/common.dart';
import 'package:fitness/core/models/workout_schedule_model.dart';
import 'package:fitness/core/repositories/workout_repository.dart';
import 'package:fitness/core/services/supabase_service.dart';

class AllSchedulesView extends StatefulWidget {
  const AllSchedulesView({super.key});

  @override
  State<AllSchedulesView> createState() => _AllSchedulesViewState();
}

class _AllSchedulesViewState extends State<AllSchedulesView> {
  late final WorkoutRepository _workoutRepository;
  List<WorkoutScheduleModel> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _workoutRepository = WorkoutRepository();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId != null) {
        final schedules = await _workoutRepository.getUserWorkoutSchedules(userId);
        setState(() {
          _schedules = schedules;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading schedules: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getWorkoutImage(String workoutId) {
    switch (workoutId.toLowerCase()) {
      case 'upperbody':
        return "assets/img/Workout1.png";
      case 'lowerbody':
        return "assets/img/Workout2.png";
      case 'fullbody':
        return "assets/img/Workout3.png";
      case 'ab workout':
        return "assets/img/Workout4.png";
      case 'cardio':
        return "assets/img/Workout5.png";
      case 'strength training':
        return "assets/img/Workout6.png";
      default:
        return "assets/img/Workout1.png";
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await _workoutRepository.deleteWorkoutSchedule(scheduleId);
      _loadSchedules(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting schedule: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "All Workout Schedules",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/Workout1.png",
                        width: 100,
                        height: 100,
                        opacity: const AlwaysStoppedAnimation(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No schedules yet",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Start by adding your first workout schedule",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSchedules,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      final workoutMap = {
                        "title": schedule.workoutId,
                        "time": schedule.scheduledTime ?? "No time",
                        "image": _getWorkoutImage(schedule.workoutId),
                        "date": schedule.scheduledDate,
                        "id": schedule.id,
                      };

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.asset(
                                        workoutMap["image"] as String,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            workoutMap["title"] as String,
                                            style: TextStyle(
                                              color: TColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            dateToString(workoutMap["date"] as DateTime, formatStr: "E, dd MMMM yyyy"),
                                            style: TextStyle(
                                              color: TColor.gray,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            workoutMap["time"] as String,
                                            style: TextStyle(
                                              color: TColor.gray,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _showDeleteDialog(schedule.id!);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      child: Icon(
                                        Icons.more_vert,
                                        color: TColor.gray,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(schedule.status),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    schedule.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'skipped':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(String scheduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this workout schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSchedule(scheduleId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
