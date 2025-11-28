import 'package:fitness/view/sleep_tracker/sleep_schedule_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/today_sleep_schedule_row.dart';
import '../../core/models/sleep_model.dart';
import '../../core/models/alarm_model.dart';
import '../../core/services/fitness_data_service.dart';
import '../../core/services/alarm_service.dart';

class SleepTrackerView extends StatefulWidget {
  const SleepTrackerView({super.key});

  @override
  State<SleepTrackerView> createState() => _SleepTrackerViewState();
}

class _SleepTrackerViewState extends State<SleepTrackerView> {
  List<SleepModel> _sleepData = [];
  bool _isLoading = true;
  String? _error;
  SleepModel? _latestSleep;
  SleepModel? _lastNightSleep; // Add last night sleep
  List<AlarmModel> _userAlarms = []; // Add alarms list

  // Get today's alarms for display
  List<Map<String, dynamic>> get todaySleepArr {
    final List<Map<String, dynamic>> schedule = [];
    final today = DateTime.now();
    final todayString = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    // Add today's alarms
    for (final alarm in _userAlarms) {
      if (alarm.isEnabled) {
        // Check if alarm is for today (either no repeat days or today is in repeat days)
        bool showToday = false;
        
        if (alarm.repeatDays == null || alarm.repeatDays!.isEmpty) {
          // No repeat days - check if alarm time has passed today or is upcoming
          final alarmDateTime = DateTime(today.year, today.month, today.day, alarm.alarmTime.hour, alarm.alarmTime.minute);
          showToday = true; // Show all one-time alarms for today
        } else {
          // Has repeat days - check if today is in the repeat days
          final dayMap = {
            1: 'Mon',
            2: 'Tue', 
            3: 'Wed',
            4: 'Thu',
            5: 'Fri',
            6: 'Sat',
            7: 'Sun',
          };
          
          final dayName = dayMap[today.weekday];
          if (dayName != null && alarm.repeatDays!.contains(dayName)) {
            showToday = true;
          }
        }
        
        if (showToday) {
          final isBedtimeAlarm = alarm.title.toLowerCase().contains('bedtime') || 
                               alarm.title.toLowerCase().contains('sleep') ||
                               alarm.title.toLowerCase().contains('نوم');
          
          schedule.add({
            "name": alarm.title,
            "image": isBedtimeAlarm ? "assets/img/bed.png" : "assets/img/alaarm.png",
            "time": alarm.timeFormatted,
            "duration": alarm.repeatDaysFormatted.isNotEmpty ? 
                        alarm.repeatDaysFormatted : 
                        "Today",
            "alarmId": alarm.id,
            "isEnabled": alarm.isEnabled,
          });
        }
      }
    }
    
    // If no alarms for today, show sleep data or empty state
    if (schedule.isEmpty) {
      if (_latestSleep == null) {
        return [
          {
            "name": "No Alarms Today",
            "image": "assets/img/bed.png",
            "time": "No alarms scheduled",
            "duration": "Add an alarm in Schedule"
          },
        ];
      } else {
        // Show last sleep data
        return [
          {
            "name": "Last Sleep",
            "image": "assets/img/bed.png",
            "time": "${_latestSleep!.date.month.toString().padLeft(2, '0')}/${_latestSleep!.date.day.toString().padLeft(2, '0')}/${_latestSleep!.date.year} ${_latestSleep!.bedtimeFormatted}",
            "duration": "Duration: ${_latestSleep!.durationFormatted}"
          },
        ];
      }
    }
    
    return schedule;
  }

  String _getSleepQualityText(int? qualityScore) {
    if (qualityScore == null) return 'N/A';
    
    switch (qualityScore) {
      case 9:
      case 8:
        return 'Excellent';
      case 7:
        return 'Good';
      case 6:
      case 5:
        return 'Fair';
      case 4:
      case 3:
        return 'Poor';
      default:
        return 'Very Poor';
    }
  }

  List findEatArr = [
    {
      "name": "Breakfast",
      "image": "assets/img/m_3.png",
      "number": "120+ Foods"
    },
    {"name": "Lunch", "image": "assets/img/m_4.png", "number": "130+ Foods"},
  ];

  List<int> showingTooltipOnSpots = [4];

  @override
  void initState() {
    super.initState();
    _loadSleepData();
    _loadUserAlarms();
  }

  Future<void> _loadUserAlarms() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final alarms = await AlarmService.getUserAlarms(userId);
        setState(() {
          _userAlarms = alarms;
        });
      }
    } catch (e) {
      print('Error loading alarms in sleep tracker: $e');
    }
  }

  Future<void> _loadSleepData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // Load sleep data
      final sleepData = await FitnessDataService.getSleepDataForLastDays(user.id, 30); // Get last 30 days
      
      // Find last night's sleep record
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));
      
      SleepModel? lastNight;
      for (final sleep in sleepData) {
        if (sleep.date.isAfter(yesterdayStart) && sleep.date.isBefore(yesterdayEnd)) {
          lastNight = sleep;
          break;
        }
      }
      
      // Get latest sleep record (for chart)
      final latestSleep = sleepData.isNotEmpty ? sleepData.first : null;

      setState(() {
        _sleepData = sleepData;
        _latestSleep = latestSleep;
        _lastNightSleep = lastNight;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = 'Failed to load sleep data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final tooltipsOnBar = lineBarsData1[0];
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
          "Sleep Tracker",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {
              _loadSleepData(); // Refresh sleep data
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                Icons.refresh,
                size: 20,
                color: TColor.black,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: RefreshIndicator(
        onRefresh: _loadSleepData,
        color: TColor.primaryColor2,
        backgroundColor: TColor.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(left: 15),
                      height: media.width * 0.5,
                      width: double.maxFinite,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator(color: TColor.primaryColor2))
                          : _error != null
                              ? Center(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: TColor.gray, fontSize: 14),
                                  ),
                                )
                              : LineChart(
                        LineChartData(
                          showingTooltipIndicators:
                              showingTooltipOnSpots.map((index) {
                            return ShowingTooltipIndicators([
                              LineBarSpot(
                                tooltipsOnBar,
                                lineBarsData1.indexOf(tooltipsOnBar),
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
                                      strokeWidth: 1,
                                      strokeColor: TColor.primaryColor2,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 5,
                              getTooltipItems:
                                  (List<LineBarSpot> lineBarsSpot) {
                                return lineBarsSpot.map((lineBarSpot) {
                                  return LineTooltipItem(
                                    "${lineBarSpot.y.toInt()} hours",
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
                          minY: -0.01,
                          maxY: 10.01,
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
                            horizontalInterval: 2,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: TColor.gray.withOpacity(0.15),
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
                      )),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    width: double.maxFinite,
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              _lastNightSleep != null 
                                  ? "Last Night Sleep"
                                  : "No Sleep Data",
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              _lastNightSleep?.durationFormatted ?? "0h 0m",
                              style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (_lastNightSleep != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Quality: ${_lastNightSleep!.qualityScore ?? 'N/A'}/10",
                                style: TextStyle(
                                    color: TColor.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "${_lastNightSleep!.bedtimeFormatted} - ${_lastNightSleep!.wakeTimeFormatted}",
                                style: TextStyle(
                                    color: TColor.white.withOpacity(0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Image.asset(
                            "assets/img/SleepGraph.png",
                            width: double.maxFinite,
                          )
                        ]),
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
                            "Daily Sleep Schedule",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          height: 25,
                          child: RoundButton(
                            title: "Check",
                            type: RoundButtonType.bgGradient,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SleepScheduleView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Text(
                    "Today Schedule",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.03,
                  ),
                  _latestSleep != null
                      ? Column(
                          children: [
                            TodaySleepScheduleRow(
                              sObj: {
                                "name": "Bedtime",
                                "image": "assets/img/bed.png",
                                "time": _latestSleep!.bedtimeFormatted,
                                "duration": _latestSleep!.durationFormatted,
                              },
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: todaySleepArr.length,
                          itemBuilder: (context, index) {
                            var sObj = todaySleepArr[index] as Map? ?? {};
                            return TodaySleepScheduleRow(
                              sObj: sObj,
                              onAlarmUpdated: () {
                                _loadUserAlarms(); // Refresh alarms when updated
                              },
                            );
                          }),
                ],
              ),
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
    ));
  }

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2,
          TColor.primaryColor1,
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2,
            TColor.white,
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        spots: _getChartSpots(),
      );

  List<FlSpot> _getChartSpots() {
    if (_sleepData.isEmpty) {
      // Default data when no sleep data available
      return [
        const FlSpot(1, 0),
        const FlSpot(2, 0),
        const FlSpot(3, 0),
        const FlSpot(4, 0),
        const FlSpot(5, 0),
        const FlSpot(6, 0),
        const FlSpot(7, 0),
      ];
    }

    // Create spots for the last 7 days with real sleep hours
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      // Find sleep record for this day
      final sleepRecord = _sleepData.firstWhere(
        (sleep) => sleep.date.isAfter(dayStart.subtract(const Duration(hours: 1))) && 
                   sleep.date.isBefore(dayEnd.add(const Duration(hours: 1))),
        orElse: () => SleepModel(
          id: '',
          userId: '',
          date: date,
          bedtime: dayStart,
          wakeTime: dayStart,
          durationMinutes: 0,
          qualityScore: null,
          createdAt: date,
        ),
      );
      
      // Convert minutes to hours for chart (e.g., 480 minutes = 8.0 hours)
      final hours = sleepRecord.durationMinutes / 60.0;
      spots.add(FlSpot((7 - i).toDouble(), hours));
    }
    
    return spots;
  }

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 2,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0h';
        break;
      case 2:
        text = '2h';
        break;
      case 4:
        text = '4h';
        break;
      case 6:
        text = '6h';
        break;
      case 8:
        text = '8h';
        break;
      case 10:
        text = '10h';
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
    
    // Show actual day names for the last 7 days
    final now = DateTime.now();
    final dayIndex = (value.toInt() - 1).clamp(0, 6);
    final date = now.subtract(Duration(days: 6 - dayIndex));
    final dayName = _getDayName(date.weekday);
    
    text = Text(dayName, style: style);
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
