import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitness/core/repositories/workout_repository.dart';
import 'package:fitness/core/models/workout_schedule_model.dart';
import 'package:fitness/core/services/supabase_service.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  DateTime? _selectedTime;
  DateTime? _selectedDate; // Make it nullable to avoid errors
  String _selectedWorkout = 'Upperbody';
  String _selectedDifficulty = 'Beginner';
  String _customRepetitions = '';
  String _customWeights = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize variables to prevent null errors
    _customRepetitions = '';
    _customWeights = '';
    _selectedDate = widget.date; // Use the passed date as default
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
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
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
      ),
      backgroundColor: TColor.white,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Image.asset(
                "assets/img/date.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: TColor.gray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          () {
                            final selectedDate = _selectedDate;
                            return selectedDate != null 
                                ? dateToString(selectedDate, formatStr: "E, dd MMMM yyyy")
                                : "Select date";
                          }(),
                          style: TextStyle(color: TColor.gray, fontSize: 14),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: TColor.gray,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Time",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Container(
            height: 200,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newDate) {
                setState(() {
                  _selectedTime = newDate;
                });
              },
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Details Workout",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/img/choose_workout.png",
              title: "Choose Workout",
              time: _selectedWorkout,
              color: TColor.lightGray,
              onPressed: () {
                _showWorkoutSelection();
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/difficulity.png",
              title: "Difficulity",
              time: _selectedDifficulty,
              color: TColor.lightGray,
              onPressed: () {
                _showDifficultySelection();
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Repetitions",
              time: (_customRepetitions ?? '').isEmpty ? "Not set" : _customRepetitions,
              color: TColor.lightGray,
              onPressed: () {
                _showRepetitionsDialog();
              }),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Weights",
              time: (_customWeights ?? '').isEmpty ? "Not set" : _customWeights,
              color: TColor.lightGray,
              onPressed: () {
                _showWeightsDialog();
              }),
          const SizedBox(
            height: 30,
          ),
          RoundButton(
            title: _isLoading ? "Saving..." : "Save", 
            onPressed: _isLoading ? null : _saveSchedule
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    ),
    );
  }

  void _showWorkoutSelection() {
    final workouts = ['Upperbody', 'Lowerbody', 'Fullbody', 'AB Workout', 'Cardio', 'Strength Training'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...workouts.map((workout) => ListTile(
              title: Text(workout),
              onTap: () {
                setState(() {
                  _selectedWorkout = workout;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDifficultySelection() {
    final difficulties = ['Beginner', 'Intermediate', 'Advanced'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Difficulty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...difficulties.map((difficulty) => ListTile(
              title: Text(difficulty),
              onTap: () {
                setState(() {
                  _selectedDifficulty = difficulty;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showRepetitionsDialog() {
    final controller = TextEditingController(text: _customRepetitions ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Repetitions'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter number of repetitions',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customRepetitions = controller.text ?? '';
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWeightsDialog() {
    final controller = TextEditingController(text: _customWeights ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Weights'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter weight (kg or lbs)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customWeights = controller.text ?? '';
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_selectedTime == null) {
      _showErrorSnackBar('Please select a time');
      return;
    }
    
    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a date');
      return;
    }

    final userId = SupabaseService.getCurrentUserId();
    if (userId == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simple approach: save schedule with workout name instead of UUID
      // We'll modify the database to accept workout names
      final schedule = WorkoutScheduleModel(
        userId: userId,
        workoutId: _selectedWorkout, // Use workout name directly
        scheduledDate: _selectedDate!, // Use selected date with null assertion
        scheduledTime: _selectedTime != null 
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
        status: 'scheduled',
      );

      await _workoutRepository.createWorkoutSchedule(schedule);
      
      _showSuccessSnackBar('Schedule saved successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to save schedule: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: TColor.primaryColor1,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
