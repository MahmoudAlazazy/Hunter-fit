import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/view/workout_tracker/add_schedule_view.dart';
import 'package:fitness/view/workout_tracker/muscle_group_selection_view.dart';
import 'package:fitness/view/workout_tracker/all_schedules_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/upcoming_workout_row.dart';
import '../../core/repositories/workout_repository.dart';
import '../../core/services/supabase_service.dart';

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key});

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  WorkoutRepository? _workoutRepository;
  List latestArr = [];
  bool _isLoadingSchedules = false;
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoadingChartData = false;

  @override
  void initState() {
    super.initState();
    _workoutRepository = WorkoutRepository();
    _loadScheduledWorkouts();
    _loadChartData();
  }

  Future<void> _loadScheduledWorkouts() async {
    if (_workoutRepository == null) return;
    
    setState(() {
      _isLoadingSchedules = true;
    });

    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId != null) {
        print('Loading schedules for user: $userId');
        final schedules = await _workoutRepository!.getUserWorkoutSchedules(userId);
        print('Found ${schedules.length} schedules');
        
        // Convert schedules to the format expected by UpcomingWorkoutRow
        final workoutMaps = schedules.map((schedule) {
          print('Schedule: ${schedule.workoutId} on ${schedule.scheduledDate} at ${schedule.scheduledTime}');
          return {
            "title": schedule.workoutId,
            "time": schedule.scheduledTime ?? "No time",
            "image": _getWorkoutImage(schedule.workoutId),
            "date": schedule.scheduledDate,
            "id": schedule.id,
          };
        }).toList();

        // Sort by date and time
        workoutMaps.sort((a, b) {
          final dateA = a["date"] as DateTime;
          final dateB = b["date"] as DateTime;
          return dateA.compareTo(dateB);
        });

        print('Displaying ${workoutMaps.length} workouts');

        setState(() {
          latestArr = workoutMaps.take(2).toList(); // Show only 2 upcoming workouts
        });
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error loading schedules: $e');
      setState(() {
        latestArr = []; // Clear on error
      });
    } finally {
      setState(() {
        _isLoadingSchedules = false;
      });
    }
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isLoadingChartData = true;
    });

    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId != null) {
        // Get workout schedules for the last 7 days
        final now = DateTime.now();
        final weekAgo = now.subtract(Duration(days: 7));
        
        final response = await SupabaseService.client
            .from('workout_schedules')
            .select()
            .eq('user_id', userId)
            .gte('scheduled_date', weekAgo.toIso8601String())
            .lte('scheduled_date', now.toIso8601String())
            .order('scheduled_date', ascending: true);
        
        // Group by day and count workouts
        final Map<String, int> dailyWorkoutCount = {};
        for (final schedule in response) {
          final date = DateTime.parse(schedule['scheduled_date']);
          final dateKey = '${date.year}-${date.month}-${date.day}';
          dailyWorkoutCount[dateKey] = (dailyWorkoutCount[dateKey] ?? 0) + 1;
        }
        
        // Generate chart data for the last 7 days
        final chartData = <Map<String, dynamic>>[];
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month}-${date.day}';
          final count = dailyWorkoutCount[dateKey] ?? 0;
          
          chartData.add({
            'day': _getDayName(date.weekday),
            'count': count,
            'date': date,
          });
        }
        
        print('Generated chart data: ${chartData.length} days');
        setState(() {
          _chartData = chartData;
        });
      }
    } catch (e) {
      print('Error loading chart data: $e');
    } finally {
      setState(() {
        _isLoadingChartData = false;
      });
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
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
        return "assets/img/Workout1.png";
      case 'strength training':
        return "assets/img/Workout6.png";
      default:
        return "assets/img/Workout1.png";
    }
  }

  List whatArr = [
    {
      "image": "assets/img/what_1.png",
      "title": "Fullbody Workout",
      "exercises": "11 Exercises",
      "time": "32mins"
    },
    {
      "image": "assets/img/what_2.png",
      "title": "Lowebody Workout",
      "exercises": "12 Exercises",
      "time": "40mins"
    },
    {
      "image": "assets/img/what_3.png",
      "title": "AB Workout",
      "exercises": "14 Exercises",
      "time": "20mins"
    }
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    // Responsive breakpoint
    final bool isSmallScreen = media.width < 600;
    final bool isTabletScreen = media.width >= 600 && media.width < 900;
    final bool isLargeScreen = media.width >= 900;
    
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              // pinned: true,
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
                "Workout Tracker",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
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
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: const SizedBox(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: media.width * 0.5,
                width: double.maxFinite,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: false,
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? response) {
                        if (response == null || response.lineBarSpots == null) {
                          return;
                        }
                        // if (event is FlTapUpEvent) {
                        //   final spotIndex =
                        //       response.lineBarSpots!.first.spotIndex;
                        //   showingTooltipOnSpots.clear();
                        //   setState(() {
                        //     showingTooltipOnSpots.add(spotIndex);
                        //   });
                        // }
                      },
                      mouseCursorResolver:
                          (FlTouchEvent event, LineTouchResponse? response) {
                        if (response == null || response.lineBarSpots == null) {
                          return SystemMouseCursors.basic;
                        }
                        return SystemMouseCursors.click;
                      },
                      getTouchedSpotIndicator:
                          (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            const FlLine(
                              color: Colors.transparent,
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
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
                    lineBarsData: lineBarsData1,
                    minY: -0.5,
                    maxY: 110,
                    titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: bottomTitles,
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: rightTitles,
                        )),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 25,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: TColor.white.withOpacity(0.15),
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
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                        color: TColor.gray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Daily Workout Schedule",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: isSmallScreen ? 10 : 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: isSmallScreen ? 60 : 70,
                          height: isSmallScreen ? 22 : 25,
                          child: RoundButton(
                            title: "Check",
                            type: RoundButtonType.bgGradient,
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w400,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddScheduleView(
                                    date: DateTime.now(),
                                  ),
                                ),
                              ).then((_) {
                                // Refresh the schedules when returning from AddScheduleView
                                _loadScheduledWorkouts();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Upcoming Workout",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllSchedulesView(),
                            ),
                          );
                        },
                        child: Text(
                          "See More",
                          style: TextStyle(
                              color: TColor.gray,
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                  _isLoadingSchedules
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : latestArr.isEmpty
                          ? Center(
                              child: Text(
                                "No upcoming workouts",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: latestArr.length,
                              itemBuilder: (context, index) {
                                var wObj = latestArr[index] as Map? ?? {};
                                return UpcomingWorkoutRow(wObj: wObj);
                              }),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "What Do You Want to Train",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MuscleGroupSelectionView(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: TColor.primaryG,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Muscle Group",
                            style: TextStyle(
                                color: TColor.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: TColor.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineTouchData get lineTouchData1 => const LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
        ),
      );

  List<LineChartBarData> get lineBarsData1 {
    if (_chartData.isEmpty) {
      return [lineChartBarData1_1, lineChartBarData1_2];
    }
    
    // Generate real data points
    final spots = _chartData.asMap().entries.map((entry) {
      return FlSpot(
        (entry.key + 1).toDouble(),
        (entry.value['count'] as int).toDouble(),
      );
    }).toList();
    
    return [
      LineChartBarData(
        isCurved: true,
        color: TColor.white,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: TColor.white,
            strokeWidth: 2,
            strokeColor: TColor.primaryColor1,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              TColor.primaryColor1.withOpacity(0.3),
              TColor.primaryColor2.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        spots: spots,
      ),
    ];
  }

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: TColor.white,
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
        color: TColor.white.withOpacity(0.5),
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
    if (_chartData.isEmpty) {
      // Default values when no data
      switch (value.toInt()) {
        case 0:
          return const Text('0');
        case 1:
          return const Text('1');
        case 2:
          return const Text('2');
        case 3:
          return const Text('3');
        default:
          return const SizedBox.shrink();
      }
    }
    
    // Use real data
    final index = value.toInt() - 1;
    if (index >= 0 && index < _chartData.length) {
      final count = _chartData[index]['count'] as int;
      return Text(
        count.toString(),
        style: TextStyle(
          color: TColor.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.white,
      fontSize: 12,
    );
    
    if (_chartData.isEmpty) {
      // Default values when no data
      switch (value.toInt()) {
        case 1:
          return Text('Sun', style: style);
        case 2:
          return Text('Mon', style: style);
        case 3:
          return Text('Tue', style: style);
        case 4:
          return Text('Wed', style: style);
        case 5:
          return Text('Thu', style: style);
        case 6:
          return Text('Fri', style: style);
        case 7:
          return Text('Sat', style: style);
        default:
          return const SizedBox.shrink();
      }
    }
    
    // Use real data
    final index = value.toInt() - 1;
    if (index >= 0 && index < _chartData.length) {
      final day = _chartData[index]['day'] as String;
      return Text(day, style: style);
    }
    
    return const SizedBox.shrink();
  }
}
