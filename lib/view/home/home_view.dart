import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/workout_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/colo_extension.dart';
import '../../core/models/workout_group_model.dart';
import '../../core/services/workout_group_service.dart';
import '../../core/services/fitness_data_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/sleep_model.dart';
import '../workout_tracker/workout_group_detail_view.dart';
import '../workout_tracker/all_workout_groups_view.dart';
import 'activity_tracker_view.dart';
import 'notification_view.dart';

class WorkoutCompletionData {
  final DateTime date;
  final int completedCount;
  final int totalWorkouts;
  final List<WorkoutGroupModel> completedWorkouts;
  final List<Map<String, dynamic>> scheduledWorkouts;

  WorkoutCompletionData({
    required this.date,
    required this.completedCount,
    required this.totalWorkouts,
    required this.completedWorkouts,
    this.scheduledWorkouts = const [],
  });
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Water tracking variables
  double _currentWaterAmount = 2.0; // Current water amount in liters
  double _targetWaterAmount = 4.0; // Target water amount in liters
  bool _isGoalSet = false; // Track if goal has been set
  DateTime? _lastGoalSetDate; // Track when goal was last set
  
  // Water intake history with timestamps
  final List<Map<String, dynamic>> _waterIntakeHistory = [];
  
  // Animation controller for water button
  bool _isWaterButtonPressed = false;
  
  // Real user statistics from Supabase
  Map<String, dynamic>? todayStats;
  bool isLoadingTodayStats = true;
  
  // Real workout data from Supabase
  List<Map<String, dynamic>> lastWorkouts = [];
  bool isLoadingLastWorkouts = true;
  
  List<WorkoutGroupModel> workoutGroups = [];
  bool isLoadingWorkoutGroups = true;
  List<int> showingTooltipOnSpots = [21];

  // Sleep data variables
  SleepModel? _latestSleepData;
  bool _isLoadingSleepData = false;
  String? _sleepError;

  // Workout completion chart variables
  String _selectedPeriod = "Week";
  bool _isLoadingChartData = false;
  List<WorkoutCompletionData> _chartData = [];
  int _completedWorkoutsCount = 0;
  double _maxYValue = 10;

  // BMI state
  double? _latestBMIValue;
  String? _latestBMICategory; // english category for storage
  bool _isLoadingBMI = false;
  List<Map<String, dynamic>> _bmiHistory = [];

  // User profile state
  String? _userFullName;
  bool _isLoadingUserProfile = false;
  
  // Calorie tracking
  final double _dailyCalorieGoal = 2000.0; // Default daily calorie goal
  final ValueNotifier<double> _calorieProgressNotifier = ValueNotifier(0.0);

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40)
      ];

  // Dynamic water intake data based on history
  List<Map<String, dynamic>> get waterArr {
    if (_waterIntakeHistory.isEmpty) {
      return [
        {"title": "Water Intake", "subtitle": "Stay hydrated"},
      ];
    }
    
    // Group water intake by time periods and show recent additions
    final now = DateTime.now();
    final Map<String, List<Map<String, dynamic>>> periods = {
      "6am - 8am": [],
      "9am - 11am": [],
      "11am - 2pm": [],
      "2pm - 4pm": [],
      "4pm - now": [],
    };
    
    for (final intake in _waterIntakeHistory) {
      final time = intake['timestamp'] as DateTime;
      final amount = intake['amount'] as double;
      final hour = time.hour;
      
      String periodKey;
      if (hour >= 6 && hour < 9) {
        periodKey = "6am - 8am";
      } else if (hour >= 9 && hour < 12) {
        periodKey = "9am - 11am";
      } else if (hour >= 12 && hour < 15) {
        periodKey = "11am - 2pm";
      } else if (hour >= 15 && hour < 17) {
        periodKey = "2pm - 4pm";
      } else {
        periodKey = "4pm - now";
      }
      
      periods[periodKey]!.add({
        "amount": amount,
        "time": time,
        "timeStr": "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
      });
    }
    
    // Create display list with time information
    List<Map<String, dynamic>> result = [];
    periods.forEach((period, intakes) {
      if (intakes.isNotEmpty) {
        double totalAmount = intakes.fold(0.0, (sum, intake) => sum + intake['amount']);
        String timeInfo = intakes.length == 1 
          ? intakes.first['timeStr']
          : "${intakes.length} times";
        
        result.add({
          "title": period,
          "subtitle": "${(totalAmount * 1000).toInt()}ml • $timeInfo",
        });
      }
    });
    
    return result.isNotEmpty ? result : [
      {"title": "Water Intake", "subtitle": "Stay hydrated"},
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadWorkoutGroups();
    _loadSleepData();
    _loadWaterGoal();
    _loadBMIData();
    _loadLastWorkouts();
    _loadTodayWaterIntake();
    _loadTodayStats();
    _loadUserProfile();
  }

  Future<void> _loadTodayStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoadingTodayStats = false;
      });
      return;
    }

    try {
      setState(() {
        isLoadingTodayStats = true;
      });

      // Load today's activity data
      final activity = await FitnessDataService.getTodayActivity(user.id);
      final heartRate = await FitnessDataService.getLatestHeartRate(user.id);
      
      // Calculate today's calories burned from workouts
      double caloriesBurned = _calculateTotalCaloriesBurned();
      
      // Get today's steps from activity data or use default
      int steps = activity?['steps'] ?? 7421;
      
      if (mounted) {
        setState(() {
          todayStats = {
            'steps': steps,
            'calories_burned': caloriesBurned.round(),
            'active_minutes': activity?['active_minutes'] ?? 45,
            'heart_rate': heartRate?['bpm'] ?? 72,
          };
          
          // Update calorie progress
          final progressPercentage = _dailyCalorieGoal > 0 
              ? (caloriesBurned / _dailyCalorieGoal).clamp(0.0, 1.0) * 100
              : 0.0;
          _calorieProgressNotifier.value = progressPercentage;
          
          isLoadingTodayStats = false;
        });
      }
    } catch (e) {
      print('Error loading today stats: $e');
      if (mounted) {
        setState(() {
          isLoadingTodayStats = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingUserProfile = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoadingUserProfile = true;
      });

      // Load user profile data
      final profile = await SupabaseService.getCurrentUserProfile();
      
      if (mounted) {
        setState(() {
          // Try to get name from profile first, then from auth metadata
          if (profile?['full_name'] != null && profile!['full_name'].toString().isNotEmpty) {
            _userFullName = profile['full_name'];
          } else if (user.userMetadata?['full_name'] != null && user.userMetadata!['full_name'].toString().isNotEmpty) {
            _userFullName = user.userMetadata!['full_name'];
          } else if (profile?['username'] != null && profile!['username'].toString().isNotEmpty) {
            _userFullName = profile['username'];
          } else if (user.email != null) {
            // Use email part before @ as fallback
            final email = user.email!;
            _userFullName = email.split('@')[0];
          } else {
            _userFullName = 'User';
          }
          _isLoadingUserProfile = false;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          // Fallback to auth metadata or email
          final user = Supabase.instance.client.auth.currentUser;
          if (user?.userMetadata?['full_name'] != null && user!.userMetadata!['full_name'].toString().isNotEmpty) {
            _userFullName = user.userMetadata!['full_name'];
          } else if (user?.email != null) {
            final email = user!.email!;
            _userFullName = email.split('@')[0];
          } else {
            _userFullName = 'User';
          }
          _isLoadingUserProfile = false;
        });
      }
    }
  }

  Future<void> _loadLastWorkouts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoadingLastWorkouts = false;
      });
      return;
    }

    try {
      setState(() {
        isLoadingLastWorkouts = true;
      });

      final workouts = await FitnessDataService.getLastWorkouts(user.id, limit: 3);
      
      if (mounted) {
        setState(() {
          lastWorkouts = workouts.map((workout) => {
            'name': workout.title,
            'image': 'assets/img/Workout1.png', // Default image since WorkoutModel doesn't have imageUrl
            'kcal': ((workout.durationMinutes ?? 20) * 8).toString(), // Estimate calories: 8 per minute
            'time': (workout.durationMinutes ?? 20).toString(),
            'progress': 0.0, // Default progress since WorkoutModel doesn't have progress
          }).toList();
          isLoadingLastWorkouts = false;
        });
      }
    } catch (e) {
      print('Error loading last workouts: $e');
      if (mounted) {
        setState(() {
          isLoadingLastWorkouts = false;
        });
      }
    }
  }

  Future<void> _loadTodayWaterIntake() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final totalIntake = await FitnessDataService.getTotalWaterIntakeToday(user.id);
      final goal = await FitnessDataService.getDailyWaterGoalLiters();
      
      if (mounted) {
        setState(() {
          _currentWaterAmount = totalIntake / 1000.0; // Convert ml to liters
          _targetWaterAmount = goal;
        });
      }
    } catch (e) {
      print('Error loading water intake: $e');
    }
  }

  Future<void> _loadWaterGoal() async {
    final goal = await FitnessDataService.getDailyWaterGoalLiters();
    if (!mounted) return;
    setState(() {
      _targetWaterAmount = goal;
    });
  }

  Future<void> _loadWorkoutGroups() async {
    try {
      final workoutGroupService = WorkoutGroupService();
      final groups = await workoutGroupService.getWorkoutGroups();
      
      if (mounted) {
        setState(() {
          workoutGroups = groups;
          isLoadingWorkoutGroups = false;
        });
      }
      
      // Load chart data after workout groups are loaded
      _loadWorkoutCompletionData();
    } catch (e) {
      print('Error loading workout groups: $e');
      if (mounted) {
        setState(() {
          isLoadingWorkoutGroups = false;
        });
      }
    }
  }

  Future<void> _loadBMIData() async {
    try {
      setState(() {
        _isLoadingBMI = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoadingBMI = false;
          _latestBMIValue = null;
          _latestBMICategory = null;
          _bmiHistory = [];
        });
        return;
      }

      final latest = await FitnessDataService.getLatestBMI(user.id);
      final history = await FitnessDataService.getBMIHistory(user.id, limit: 20);

      setState(() {
        _latestBMIValue = latest != null ? (latest['bmi'] as num?)?.toDouble() : null;
        _latestBMICategory = latest != null ? latest['category'] as String? : null;
        _bmiHistory = history;
        _isLoadingBMI = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBMI = false;
      });
    }
  }

  String _classifyBMIDisplay(double bmi) {
    if (bmi < 18.5) return 'نحيف';
    if (bmi < 25) return 'وزن طبيعي';
    if (bmi < 30) return 'زيادة وزن';
    return 'سمنة';
  }

  String _classifyBMIStorage(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  Future<void> _showBMIDialog() async {
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('حساب مؤشر كتلة الجسم'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'الطول (سم)',
                      hintText: 'مثال: 170',
                    ),
                    validator: (v) {
                      final val = double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (val == null) return 'أدخل رقماً صحيحاً';
                      if (val < 50 || val > 300) return 'الطول يجب أن يكون بين 50 و 300 سم';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'الوزن (كجم)',
                      hintText: 'مثال: 70.5',
                    ),
                    validator: (v) {
                      final val = double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (val == null) return 'أدخل رقماً صحيحاً';
                      if (val < 10 || val > 400) return 'الوزن يجب أن يكون بين 10 و 400 كجم';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: RoundButton(
                      title: 'حساب وحفظ',
                      type: RoundButtonType.bgSGradient,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final heightCm = double.tryParse(heightController.text.replaceAll(',', '.')) ?? 0.0;
                        final weightKg = double.tryParse(weightController.text.replaceAll(',', '.')) ?? 0.0;
                        
                        // Validate inputs to prevent NaN
                        if (heightCm <= 0 || weightKg <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى إدخال قيم صحيحة موجبة للطول والوزن')),
                          );
                          return;
                        }
                        
                        final heightM = heightCm / 100.0;
                        final bmi = weightKg / (heightM * heightM);
                        
                        // Validate BMI result
                        if (!bmi.isFinite || bmi.isNaN) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('حدث خطأ في حساب مؤشر كتلة الجسم')),
                          );
                          return;
                        }
                        final storageCategory = _classifyBMIStorage(bmi);
                        final displayCategory = _classifyBMIDisplay(bmi);

                        final user = Supabase.instance.client.auth.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى تسجيل الدخول لحفظ النتيجة')),
                          );
                          return;
                        }

                        final inserted = await FitnessDataService.createBMIRecord(
                          userId: user.id,
                          heightCm: heightCm,
                          weightKg: weightKg,
                          bmi: double.parse(bmi.toStringAsFixed(2)),
                          category: storageCategory,
                        );

                        if (inserted != null) {
                          setState(() {
                            _latestBMIValue = (inserted['bmi'] as num).toDouble();
                            _latestBMICategory = inserted['category'] as String;
                            _bmiHistory.insert(0, inserted);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('BMI: ${bmi.toStringAsFixed(2)} • $displayCategory')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('فشل حفظ النتيجة')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('السجل السابق', style: TextStyle(color: TColor.black, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: _bmiHistory.isEmpty
                        ? const Center(child: Text('لا يوجد سجلات بعد'))
                        : ListView.builder(
                            itemCount: _bmiHistory.length,
                            itemBuilder: (context, index) {
                              final item = _bmiHistory[index];
                              final bmiVal = (item['bmi'] as num?)?.toDouble();
                              final dateStr = (item['created_at'] ?? item['date']) as String?;
                              final categoryEn = item['category'] as String?;
                              final categoryAr = bmiVal != null ? _classifyBMIDisplay(bmiVal) : '';
                              return ListTile(
                                dense: true,
                                title: Text('BMI: ${bmiVal?.toStringAsFixed(2) ?? '-'}'),
                                subtitle: Text('$categoryAr • ${dateStr ?? ''}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSleepData() async {
    try {
      setState(() {
        _isLoadingSleepData = true;
        _sleepError = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _sleepError = 'User not authenticated';
          _isLoadingSleepData = false;
        });
        return;
      }

      final latestSleep = await FitnessDataService.getSleepForDate(user.id, DateTime.now());
      
      if (mounted) {
        setState(() {
          _latestSleepData = latestSleep;
          _isLoadingSleepData = false;
        });
      }
    } catch (e) {
      print('Error loading sleep data: $e');
      if (mounted) {
        setState(() {
          _sleepError = 'Failed to load sleep data';
          _isLoadingSleepData = false;
        });
      }
    }
  }

  Future<void> _loadWorkoutCompletionData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingChartData = true;
    });

    try {
      final workoutGroupService = WorkoutGroupService();
      final allGroups = await workoutGroupService.getWorkoutGroups();
      
      // Load upcoming workouts from Supabase
      final userId = SupabaseService.getCurrentUserId();
      List<Map<String, dynamic>> upcomingWorkouts = [];
      
      if (userId != null) {
        try {
          // For now, we'll use empty schedules since getUpcomingSchedules doesn't exist yet
          final schedules = <Map<String, dynamic>>[];
          print('Loaded ${schedules.length} upcoming schedules for chart');
          upcomingWorkouts = schedules;
        } catch (e) {
          print('Error loading schedules for chart: $e');
        }
      }
      
      // Calculate date range based on selected period
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case "Week":
          startDate = now.subtract(Duration(days: now.weekday - 1)); // Start of current week
          break;
        case "Month":
          startDate = DateTime(now.year, now.month, 1); // Start of current month
          break;
        case "Custom":
        default:
          startDate = now.subtract(const Duration(days: 7)); // Last 7 days
          break;
      }

      // Generate chart data for each day in the period
      final chartData = <WorkoutCompletionData>[];
      int totalCompleted = 0;
      
      for (int i = 0; i < (_selectedPeriod == "Month" ? 30 : 7); i++) {
        final date = startDate.add(Duration(days: i));
        final completedWorkouts = <WorkoutGroupModel>[];
        final scheduledWorkouts = <Map<String, dynamic>>[];
        
        // Check which workouts were completed on this date
        for (final group in allGroups) {
          for (final exercise in group.exercises) {
            if (exercise.isCompleted && exercise.completedDate != null) {
              final completedDate = DateTime(
                exercise.completedDate!.year,
                exercise.completedDate!.month,
                exercise.completedDate!.day,
              );
              
              if (completedDate == DateTime(date.year, date.month, date.day)) {
                completedWorkouts.add(group);
                totalCompleted++;
                break; // Count each workout group only once per day
              }
            }
          }
        }
        
        // Check which workouts are scheduled on this date
        for (final schedule in upcomingWorkouts) {
          try {
            final scheduledDate = DateTime.parse(schedule['scheduled_date']);
            if (scheduledDate.year == date.year && 
                scheduledDate.month == date.month && 
                scheduledDate.day == date.day) {
              scheduledWorkouts.add(schedule);
            }
          } catch (e) {
            print('Error parsing schedule date: $e');
          }
        }
        
        chartData.add(WorkoutCompletionData(
          date: date,
          completedCount: completedWorkouts.length,
          totalWorkouts: allGroups.length,
          completedWorkouts: completedWorkouts,
          scheduledWorkouts: scheduledWorkouts, // Add scheduled workouts
        ));
      }

      if (mounted) {
        setState(() {
          _chartData = chartData;
          _completedWorkoutsCount = totalCompleted;
          _maxYValue = chartData.isNotEmpty 
              ? (chartData.map((d) => d.completedCount).reduce((a, b) => a > b ? a : b) + 1).toDouble()
              : 5.0;
          _isLoadingChartData = false;
        });
        
        // Update calorie progress when chart data changes
        _updateCalorieProgress();
      }
    } catch (e) {
      print('Error loading workout completion data: $e');
      if (mounted) {
        setState(() {
          _isLoadingChartData = false;
        });
      }
    }
  }

  List<BarChartGroupData> _getChartBarGroups() {
    return _chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.completedCount.toDouble(),
            gradient: LinearGradient(
              colors: TColor.primaryG,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _maxYValue,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _getChartBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= _chartData.length) {
      return const SizedBox.shrink();
    }
    
    final date = _chartData[value.toInt()].date;
    String text;
    
    if (_selectedPeriod == "Month") {
      text = '${date.day}';
    } else {
      // Week view - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      text = days[date.weekday - 1];
    }
    
    return Text(
      text,
      style: TextStyle(
        color: TColor.white.withValues(alpha: 0.8),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _getChartLeftTitles(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: TextStyle(
        color: TColor.white.withValues(alpha: 0.8),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatChartDate(DateTime date) {
    // Use shorter format to avoid overlapping
    if (_selectedPeriod == "Month") {
      return '${date.day}'; // Just day number for month view
    } else {
      return '${date.day}/${date.month}'; // Simple day/month for week view
    }
  }

  // Water tracking functions
  
  // Show goal input dialog
  void _showGoalInputDialog() {
    final TextEditingController goalController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Set Daily Water Goal',
            style: TextStyle(
              color: TColor.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your daily water goal in liters:',
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: goalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 4.0',
                    hintStyle: TextStyle(color: TColor.gray),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    suffixText: 'Liters',
                    suffixStyle: TextStyle(color: TColor.gray),
                  ),
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: TColor.gray),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextButton(
                onPressed: () {
                  final goal = double.tryParse(goalController.text);
                  if (goal != null && goal > 0) {
                    setState(() {
                      _targetWaterAmount = goal;
                      _isGoalSet = true;
                      _lastGoalSetDate = DateTime.now(); // Track when goal was set
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Daily goal set to ${goal}L'),
                        backgroundColor: TColor.primaryColor1,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Set Goal',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Show water quantity selection dialog
  void _showWaterQuantityDialog() {
    final List<double> quantities = [0.25, 0.5, 0.75, 1.0, 1.5, 2.0];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Add Water',
            style: TextStyle(
              color: TColor.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select water amount:',
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: quantities.map((quantity) {
                  return SizedBox(
                    width: 120,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: TColor.primaryG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            _addWaterAmount(quantity);
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${quantity}L',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: TColor.gray),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Add specific water amount
  void _addWaterAmount(double amount) {
    // Add animation effect
    setState(() {
      _isWaterButtonPressed = true;
      // Add water amount
      _currentWaterAmount = (_currentWaterAmount + amount).clamp(0.0, _targetWaterAmount);
      
      // Add to history with timestamp
      _waterIntakeHistory.add({
        'amount': amount,
        'timestamp': DateTime.now(),
      });
    });
    
    // Reset animation after short delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isWaterButtonPressed = false;
        });
      }
    });
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      FitnessDataService.addWaterIntake(
        userId: user.id,
        amountMl: (amount * 1000).round(),
      );
    }
    
    // Show feedback if target is reached
    if (_currentWaterAmount >= _targetWaterAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Congratulations! You\'ve reached your daily water goal!'),
          backgroundColor: TColor.primaryColor1,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${amount}L of water'),
          backgroundColor: TColor.primaryColor1,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
  
  // Calculate total calories burned from completed workouts
  double _calculateTotalCaloriesBurned() {
    double totalCalories = 0.0;
    
    try {
      // Calculate calories from today's completed workouts
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final data in _chartData) {
        if (data.date.year == today.year && 
            data.date.month == today.month && 
            data.date.day == today.day) {
          // Calculate calories based on completed exercises
          for (final workout in data.completedWorkouts) {
            double workoutCalories = 0.0;
            
            // Calculate calories for each completed exercise
            for (final exercise in workout.exercises) {
              if (exercise.isCompleted) {
                // Validate exercise data to prevent NaN
                if (exercise.sets < 0) {
                  continue; // Skip invalid exercises
                }
                
                // Estimate calories based on exercise muscle group and duration
                // Default: 8 calories per minute for most exercises
                double caloriesPerMinute = 8.0;
                String muscleGroup = exercise.exercise.muscleGroup.toLowerCase();
                if (muscleGroup.contains('cardio') || muscleGroup.contains('full_body')) {
                  caloriesPerMinute = 12.0;
                } else if (muscleGroup.contains('core') || muscleGroup.contains('abs')) {
                  caloriesPerMinute = 6.0;
                } else if ((exercise.exercise.name.toLowerCase().contains('yoga') ||
                     exercise.exercise.name.toLowerCase().contains('stretch'))) {
                  caloriesPerMinute = 3.0;
                }
                              
                // Estimate duration: 5 minutes per set (including rest)
                int estimatedDurationMinutes = (exercise.sets * 5);
                if (exercise.durationSeconds != null && exercise.durationSeconds! > 0) {
                  estimatedDurationMinutes = (exercise.durationSeconds! / 60).ceil();
                }
                
                // Ensure we don't multiply by invalid values
                if (caloriesPerMinute.isFinite && estimatedDurationMinutes.isFinite && estimatedDurationMinutes > 0) {
                  workoutCalories += caloriesPerMinute * estimatedDurationMinutes;
                }
              }
            }
            
            // Ensure workoutCalories is finite before adding
            if (workoutCalories.isFinite) {
              totalCalories += workoutCalories;
            }
          }
          break;
        }
      }
    } catch (e) {
      print('Error calculating total calories burned: $e');
      return 0.0; // Return 0 on any error to prevent NaN
    }
    
    // Ensure we never return NaN or infinity
    return totalCalories.isFinite ? totalCalories : 0.0;
  }

  // Handle water button press
  void _handleWaterButtonPress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if goal was set today
    bool goalSetToday = false;
    if (_lastGoalSetDate != null) {
      final lastGoalDate = DateTime(_lastGoalSetDate!.year, _lastGoalSetDate!.month, _lastGoalSetDate!.day);
      goalSetToday = lastGoalDate == today;
    }
    
    if (!_isGoalSet || !goalSetToday) {
      // Set a default goal if not set today (hidden from user)
      setState(() {
        _targetWaterAmount = 4.0; // Default goal
        _isGoalSet = true;
        _lastGoalSetDate = DateTime.now();
      });
    }
    
    // Always show quantity selection for water addition
    _showWaterQuantityDialog();
  }

  // Get water progress ratio for progress bar
  double _getWaterProgressRatio() {
    return (_currentWaterAmount / _targetWaterAmount).clamp(0.0, 1.0);
  }
  
  // Get water button icon - always show add icon for simplicity
  IconData _getWaterButtonIcon() {
    return Icons.add; // Always show add icon
  }
  
  // Get water button gradient colors - always use primary gradient
  List<Color> _getWaterButtonGradient() {
    return TColor.primaryG; // Always use primary gradient
  }
  
  // Update calorie progress (call this when workouts are completed)
  void _updateCalorieProgress() {
    final caloriesBurned = _calculateTotalCaloriesBurned();
    
    // Handle invalid calorie values
    if (!caloriesBurned.isFinite || caloriesBurned < 0) {
      _calorieProgressNotifier.value = 0.0;
      return;
    }
    
    final progressPercentage = _dailyCalorieGoal > 0
        ? (caloriesBurned / _dailyCalorieGoal).clamp(0.0, 1.0) * 100
        : 0.0;
    _calorieProgressNotifier.value = progressPercentage;
    
    // Update todayStats as well
    if (todayStats != null) {
      setState(() {
        todayStats!['calories_burned'] = caloriesBurned.round();
      });
    }
  }
  
  // Get water button shadow color - always use primary color
  Color _getWaterButtonShadowColor() {
    return TColor.primaryColor1; // Always use primary shadow color
  }
  
  // Format last water intake time
  String _formatLastWaterTime() {
    if (_waterIntakeHistory.isEmpty) return "";
    
    final lastTime = _waterIntakeHistory.last['timestamp'] as DateTime;
    final now = DateTime.now();
    final difference = now.difference(lastTime);
    
    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours} hours ago";
    } else {
      return "${lastTime.hour.toString().padLeft(2, '0')}:${lastTime.minute.toString().padLeft(2, '0')}";
    }
  }

  List<LineChartBarData> _getLineChartData() {
    if (_chartData.isEmpty) {
      return [];
    }

    // Create spots for the line chart
    final spots = _chartData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;
      return FlSpot(index, data.completedCount.toDouble());
    }).toList();

    return [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: TColor.primaryColor1,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: TColor.primaryColor1,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: TColor.primaryColor1.withValues(alpha: 0.3),
        ),
      ),
    ];
  }

  Widget _getChartBottomTitlesLine(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index >= 0 && index < _chartData.length) {
      // Show only every other label to avoid overlapping
      if (_selectedPeriod == "Month" && index % 3 != 0) {
        return const SizedBox.shrink();
      }
      if (_selectedPeriod == "Week" && index % 2 != 0) {
        return const SizedBox.shrink();
      }
      
      final data = _chartData[index];
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 10,
        child: Text(
          _formatChartDate(data.date),
          style: TextStyle(
            color: TColor.gray,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _getChartLeftTitlesLine(double value, TitleMeta meta) {
    // Show only even numbers to avoid crowding
    if (value % 2 != 0 && value != 0) {
      return const SizedBox.shrink();
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(
        value.toInt().toString(),
        style: TextStyle(
          color: TColor.gray,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showWorkoutDetails(WorkoutCompletionData data) {
    if (data.completedWorkouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No workouts completed on ${_formatChartDate(data.date)}'),
          backgroundColor: TColor.gray,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Workouts on ${_formatChartDate(data.date)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.completedWorkouts.length,
              itemBuilder: (context, index) {
                final workout = data.completedWorkouts[index];
                return ListTile(
                  leading: Icon(Icons.fitness_center, color: TColor.primaryColor1),
                  title: Text(workout.name),
                  subtitle: Text('${workout.completedExercises}/${workout.totalExercises} exercises'),
                  trailing: Text('${(workout.completionProgress * 100).toInt()}%'),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    // Responsive breakpoint
    final bool isSmallScreen = media.width < 600;
    final bool isTabletScreen = media.width >= 600 && media.width < 900;
    final bool isLargeScreen = media.width >= 900;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2.withValues(alpha: 0.4),
            TColor.primaryColor1.withValues(alpha: 0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: const FlDotData(show: false),
        gradient: LinearGradient(
          colors: TColor.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                        Text(
                          _isLoadingUserProfile ? "Loading..." : (_userFullName ?? "User"),
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: isSmallScreen ? 14 : 18,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationView(),
                            ),
                          );
                        },
                        icon: Image.asset(
                          "assets/img/notification_active.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        ))
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.075)),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      "assets/img/bg_dots.png",
                      height: media.width * 0.4,
                      width: double.maxFinite,
                      fit: BoxFit.fitHeight,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BMI (مؤشر كتلة الجسم)",
                                style: TextStyle(
                                    color: TColor.white,
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                _latestBMIValue != null
                                    ? _classifyBMIDisplay(_latestBMIValue!)
                                    : "أدخل بياناتك لمعرفة الحالة",
                                style: TextStyle(
                                    color: TColor.white.withValues(alpha: 0.7),
                                    fontSize: isSmallScreen ? 8 : 10),
                              ),
                              SizedBox(
                                height: isSmallScreen ? media.width * 0.03 : media.width * 0.05,
                              ),
                              SizedBox(
                                  width: isSmallScreen ? 80 : 120,
                                  height: isSmallScreen ? 25 : 35,
                                  child: RoundButton(
                                      title: "عرض المزيد",
                                      type: RoundButtonType.bgSGradient,
                                      fontSize: isSmallScreen ? 8 : 12,
                                      fontWeight: FontWeight.w400,
                                      onPressed: _showBMIDialog))
                            ],
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {},
                                ),
                                startDegreeOffset: 250,
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 1,
                                centerSpaceRadius: 0,
                                sections: showingSections(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today Target",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: isSmallScreen ? 50 : 70,
                        height: isSmallScreen ? 20 : 25,
                        child: RoundButton(
                          title: "Check",
                          type: RoundButtonType.bgGradient,
                          fontSize: isSmallScreen ? 8 : 12,
                          fontWeight: FontWeight.w400,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ActivityTrackerView(),
                              ),
                            ).then((_) => _loadWaterGoal());
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "Activity Status",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.02,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: media.width * 0.4,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Heart Rate",
                                style: TextStyle(
                                    color: TColor.black,
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w700),
                              ),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                          colors: TColor.primaryG,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                      .createShader(Rect.fromLTRB(
                                          0, 0, bounds.width, bounds.height));
                                },
                                child: Text(
                                  "78 BPM",
                                  style: TextStyle(
                                      color: TColor.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: isSmallScreen ? 14 : 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        LineChart(
                          LineChartData(
                            showingTooltipIndicators:
                                showingTooltipOnSpots.map((index) {
                              return ShowingTooltipIndicators([
                                LineBarSpot(
                                  tooltipsOnBar,
                                  lineBarsData.indexOf(tooltipsOnBar),
                                  tooltipsOnBar.spots[index],
                                ),
                              ]);
                            }).toList(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return;
                                }
                                if (event is FlTapUpEvent) {
                                  final spotIndex =
                                      response.lineBarSpots!.first.spotIndex;
                                  showingTooltipOnSpots.clear();
                                  setState(() {
                                    showingTooltipOnSpots.add(spotIndex);
                                  });
                                }
                              },
                              mouseCursorResolver: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return SystemMouseCursors.basic;
                                }
                                return SystemMouseCursors.click;
                              },
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    const FlLine(
                                      color: Colors.red,
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 3,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: TColor.secondaryColor1,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                tooltipRoundedRadius: 20,
                                getTooltipItems:
                                    (List<LineBarSpot> lineBarsSpot) {
                                  return lineBarsSpot.map((lineBarSpot) {
                                    return LineTooltipItem(
                                      "${lineBarSpot.x.toInt()} mins ago",
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: lineBarsData,
                            minY: 0,
                            maxY: 130,
                            titlesData: const FlTitlesData(
                              show: false,
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        child: Row(
                          children: [
                            SimpleAnimationProgressBar(
                              height: media.width * 0.85,
                              width: media.width * 0.07,
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: const Color(0xffFFB2B1),
                              ratio: _getWaterProgressRatio(),
                              direction: Axis.vertical,
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: const Duration(seconds: 3),
                              borderRadius: BorderRadius.circular(15),
                              gradientColor: LinearGradient(
                                  colors: TColor.primaryG,
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row with title and add button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Water Intake",
                                        style: TextStyle(
                                            color: TColor.black,
                                            fontSize: isSmallScreen ? 8 : 10,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    // Add water button with animation
                                    GestureDetector(
                                      onTapDown: (_) => setState(() => _isWaterButtonPressed = true),
                                      onTapUp: (_) => setState(() => _isWaterButtonPressed = false),
                                      onTapCancel: () => setState(() => _isWaterButtonPressed = false),
                                      onTap: _handleWaterButtonPress,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        width: isSmallScreen ? 24 : 28,
                                        height: isSmallScreen ? 24 : 28,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _getWaterButtonGradient(),
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getWaterButtonShadowColor()
                                                  .withValues(alpha: _isWaterButtonPressed ? 0.1 : 0.3),
                                              blurRadius: _isWaterButtonPressed ? 4 : 8,
                                               offset: const Offset(0, 4),
                                             ),
                                           ],
                                         ),
                                         child: Container(
                                           width: isSmallScreen ? 24 : 28,
                                           height: isSmallScreen ? 24 : 28,
                                           alignment: Alignment.center,
                                           child: Icon(
                                             _getWaterButtonIcon(),
                                             color: Colors.white,
                                             size: isSmallScreen ? 16 : 18,
                                           ),
                                         ),
                                       ),
                                     ),
                                  ],
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    "${_currentWaterAmount.toStringAsFixed(1)} Liters",
                                    style: TextStyle(
                                        color: TColor.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: isSmallScreen ? 10 : 12),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: waterArr.map((wObj) {
                                    var isLast = wObj == waterArr.last;
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: TColor.secondaryColor1
                                                    .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            if (!isLast)
                                              DottedDashedLine(
                                                  height: media.width * 0.078,
                                                  width: 0,
                                                  dashColor: TColor
                                                      .secondaryColor1
                                                      .withValues(alpha: 0.5),
                                                  axis: Axis.vertical)
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      wObj["title"].toString(),
                                                      style: TextStyle(
                                                        color: TColor.gray,
                                                        fontSize: isSmallScreen ? 6 : 8,
                                                      ),
                                                    ),
                                                    ShaderMask(
                                                      blendMode: BlendMode.srcIn,
                                                      shaderCallback: (bounds) {
                                                        return LinearGradient(
                                                                colors:
                                                                    TColor.secondaryG,
                                                                begin: Alignment
                                                                    .centerLeft,
                                                                end: Alignment
                                                                    .centerRight)
                                                            .createShader(Rect.fromLTRB(
                                                                0,
                                                                0,
                                                                bounds.width,
                                                                bounds.height));
                                                      },
                                                      child: Text(
                                                        wObj["subtitle"].toString().split(' • ')[0], // Amount only
                                                        style: TextStyle(
                                                            color: TColor.white
                                                                .withValues(alpha: 0.7),
                                                            fontSize: isSmallScreen ? 8 : 10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (wObj["subtitle"].toString().contains(' • '))
                                                Expanded(
                                                  child: Text(
                                                    wObj["subtitle"].toString().split(' • ')[1], // Time info
                                                    style: TextStyle(
                                                      color: TColor.gray.withValues(alpha: 0.6),
                                                      fontSize: isSmallScreen ? 6 : 8,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: media.width * 0.05,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Sleep",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: isSmallScreen ? 8 : 10,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    _isLoadingSleepData
                                        ? "Loading..."
                                        : _sleepError != null
                                            ? "8h 0m"
                                            : _latestSleepData != null
                                                ? "${(_latestSleepData!.durationMinutes ~/ 60)}h ${_latestSleepData!.durationMinutes % 60}m"
                                                : "8h 0m",
                                    style: TextStyle(
                                        color: TColor.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: isSmallScreen ? 10 : 12),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 3),
                                Container(
                                  height: isSmallScreen ? 40 : 50,
                                  child: Image.asset("assets/img/sleep_grap.png",
                                      width: double.maxFinite,
                                      fit: BoxFit.fitWidth)
                                )
                              ]),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Calories",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: isSmallScreen ? 8 : 10,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    () {
                                      final caloriesBurned = _calculateTotalCaloriesBurned();
                                      final displayCalories = caloriesBurned.isFinite ? caloriesBurned : 0.0;
                                      return "${displayCalories.toStringAsFixed(0)} kCal";
                                    }(),
                                    style: TextStyle(
                                        color: TColor.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: isSmallScreen ? 10 : 12),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 5 : 10),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: isSmallScreen ? media.width * 0.15 : media.width * 0.18,
                                    height: isSmallScreen ? media.width * 0.15 : media.width * 0.18,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: isSmallScreen ? media.width * 0.12 : media.width * 0.14,
                                          height: isSmallScreen ? media.width * 0.12 : media.width * 0.14,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: TColor.primaryG),
                                            borderRadius: BorderRadius.circular(
                                                media.width * 0.075),
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              () {
                                                final caloriesBurned = _calculateTotalCaloriesBurned();
                                                final remainingCalories = _dailyCalorieGoal - caloriesBurned;
                                                
                                                // Handle invalid values safely
                                                if (!remainingCalories.isFinite || remainingCalories < 0) {
                                                  return "0kCal\nleft";
                                                }
                                                
                                                return "${remainingCalories.round().toStringAsFixed(0)}kCal\nleft";
                                              }(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: TColor.white,
                                                  fontSize: isSmallScreen ? 8 : 9),
                                            ),
                                          ),
                                        ),
                                        SimpleCircularProgressBar(
                                          progressStrokeWidth: isSmallScreen ? 6 : 8,
                                          backStrokeWidth: isSmallScreen ? 6 : 8,
                                          progressColors: TColor.primaryG,
                                          backColor: Colors.grey.shade100,
                                          valueNotifier: _calorieProgressNotifier,
                                          startAngle: -180,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ],
                    ))
                  ],
                ),
                SizedBox(
                  height: media.width * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Completed Workouts",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "$_completedWorkoutsCount workouts completed",
                          style: TextStyle(
                              color: TColor.gray,
                              fontSize: isSmallScreen ? 8 : 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: TColor.primaryG),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod,
                            items: ["Week", "Month", "Custom"]
                                .map((name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                            color: TColor.gray, fontSize: 14),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedPeriod = value;
                                });
                                _loadWorkoutCompletionData();
                              }
                            },
                            icon: Icon(Icons.expand_more, color: TColor.white),
                            hint: Text(
                              "Week",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                    padding: const EdgeInsets.only(left: 15),
                    height: media.width * 0.6,
                    width: double.maxFinite,
                    child: _isLoadingChartData
                        ? Center(
                            child: CircularProgressIndicator(
                              color: TColor.primaryColor1,
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              showingTooltipIndicators:
                                  showingTooltipOnSpots.map((index) {
                                return ShowingTooltipIndicators([
                                  LineBarSpot(
                                    tooltipsOnBar,
                                    lineBarsData.indexOf(tooltipsOnBar),
                                    tooltipsOnBar.spots[index],
                                  ),
                                ]);
                              }).toList(),
                              lineTouchData: LineTouchData(
                                enabled: true,
                                handleBuiltInTouches: false,
                                touchCallback: (FlTouchEvent event,
                                    LineTouchResponse? response) {
                                  if (response == null ||
                                      response.lineBarSpots == null) {
                                    return;
                                  }
                                  if (event is FlTapUpEvent) {
                                    final spotIndex =
                                        response.lineBarSpots!.first.spotIndex;
                                    showingTooltipOnSpots.clear();
                                    setState(() {
                                      showingTooltipOnSpots.add(spotIndex);
                                    });
                                  }
                                },
                                mouseCursorResolver: (FlTouchEvent event,
                                    LineTouchResponse? response) {
                                  if (response == null ||
                                      response.lineBarSpots == null) {
                                    return SystemMouseCursors.basic;
                                  }
                                  return SystemMouseCursors.click;
                                },
                                getTouchedSpotIndicator: (LineChartBarData barData,
                                    List<int> spotIndexes) {
                                  return spotIndexes.map((index) {
                                    return TouchedSpotIndicatorData(
                                      const FlLine(
                                        color: Colors.transparent,
                                      ),
                                      FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) =>
                                                FlDotCirclePainter(
                                          radius: 3,
                                          color: Colors.white,
                                          strokeWidth: 3,
                                          strokeColor: TColor.secondaryColor1,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipRoundedRadius: 20,
                                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                                    return lineBarsSpot.map((lineBarSpot) {
                                      final dataIndex = lineBarSpot.spotIndex;
                                      if (dataIndex < _chartData.length) {
                                        final data = _chartData[dataIndex];
                                        return LineTooltipItem(
                                          "${data.completedCount} workouts",
                                          const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      return null;
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: _getLineChartData(),
                              minY: -0.5,
                              maxY: _maxYValue,
                              titlesData: FlTitlesData(
                                  show: true,
                                  leftTitles: const AxisTitles(),
                                  topTitles: const AxisTitles(),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: _getChartBottomTitlesLine,
                                      reservedSize: 45,
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: _getChartLeftTitlesLine,
                                      reservedSize: 42,
                                      interval: 1,
                                    ),
                                  )),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                horizontalInterval: 1,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: TColor.gray.withValues(alpha: 0.15),
                                    strokeWidth: 2,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                  ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Workout",
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllWorkoutGroupsView(),
                          ),
                        ).then((_) {
                          // Refresh workout groups when returning from all groups view
                          _loadWorkoutGroups();
                        });
                      },
                      child: Text(
                        "See More",
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                ),
                
                // Workout Groups Section
                isLoadingWorkoutGroups
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
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
                                const SizedBox(height: 20),
                                Icon(
                                  Icons.fitness_center,
                                  size: 64,
                                  color: TColor.lightGray,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No workout groups yet",
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Create your first workout group",
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
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: workoutGroups.length,
                            itemBuilder: (context, index) {
                              final group = workoutGroups[index];
                              // Convert WorkoutGroupModel to WorkoutRow format
                              final workoutMap = {
                                "name": group.name,
                                "image": group.imagePath ?? "assets/img/Workout1.png",
                                "kcal": "${group.exercises.length * 50}", // Estimated calories
                                "time": "${group.exercises.length * 5}", // Estimated time in minutes
                                "progress": group.completionProgress,
                              };
                              return InkWell(
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
                                child: WorkoutRow(wObj: workoutMap),
                              );
                            },
                          ),
                

                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      2,
      (i) {
        var color0 = TColor.secondaryColor1;

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color0,
                value: 33,
                title: '',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                badgeWidget: Text(
                  _latestBMIValue != null ? _latestBMIValue!.toStringAsFixed(1) : '-',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ));
          case 1:
            return PieChartSectionData(
              color: Colors.white,
              value: 75,
              title: '',
              radius: 45,
              titlePositionPercentageOffset: 0.55,
            );

          default:
            throw Error();
        }
      },
    );
  }

  LineTouchData get lineTouchData1 => const LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2.withValues(alpha: 0.5),
          TColor.primaryColor1.withValues(alpha: 0.5),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.secondaryColor2.withValues(alpha: 0.5),
          TColor.secondaryColor1.withValues(alpha: 0.5),
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }


}
