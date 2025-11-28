import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:fitness/view/sleep_tracker/sleep_add_alarm_view.dart';

import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/today_sleep_schedule_row.dart';
import '../../common_widget/alarm_card_widget.dart';
import '../../core/models/sleep_model.dart';
import '../../core/models/alarm_model.dart';
import '../../core/services/fitness_data_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/alarm_notification_service.dart';

class SleepScheduleView extends StatefulWidget {
  const SleepScheduleView({super.key});

  @override
  State<SleepScheduleView> createState() => _SleepScheduleViewState();
}

class _SleepScheduleViewState extends State<SleepScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;
  SleepModel? _latestSleep;
  List<AlarmModel> _userAlarms = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get todaySleepArr {
    final List<Map<String, dynamic>> schedule = [];
    
    // Add all user alarms with appropriate images
    for (final alarm in _userAlarms) {
      final isBedtimeAlarm = alarm.title.toLowerCase().contains('bedtime') || 
                           alarm.title.toLowerCase().contains('sleep') ||
                           alarm.title.toLowerCase().contains('نوم');
      
      schedule.add({
        "name": alarm.title,
        "image": isBedtimeAlarm ? "assets/img/bed.png" : "assets/img/alaarm.png",
        "time": alarm.timeFormatted,
        "duration": alarm.repeatDaysFormatted.isNotEmpty ? 
                    alarm.repeatDaysFormatted : 
                    (isBedtimeAlarm ? "Tonight" : "Once"),
        "alarmId": alarm.id, // Store alarm ID for operations
        "isEnabled": alarm.isEnabled, // Store alarm state
      });
    }
    
    // Add sleep duration card with real data
    final sleepDuration = _calculateSleepDurationFromAlarms();
    if (sleepDuration > 0) {
      final hours = sleepDuration ~/ 60;
      final minutes = sleepDuration % 60;
      schedule.add({
        "name": "Sleep Duration",
        "image": "assets/img/bed.png",
        "time": "Calculated from alarms",
        "duration": "${hours}h ${minutes}m"
      });
    }
    
    // If no real alarms, return default mock data
    if (schedule.isEmpty) {
      return [
        {
          "name": "Bedtime",
          "image": "assets/img/bed.png",
          "time": "01/06/2023 09:00 PM",
          "duration": "in 6hours 22minutes"
        },
        {
          "name": "Alarm",
          "image": "assets/img/alaarm.png",
          "time": "02/06/2023 05:10 AM",
          "duration": "in 14hours 30minutes"
        },
      ];
    }
    
    return schedule;
  }

  // Helper methods to calculate real sleep data from alarms
  int _calculateSleepDurationFromAlarms() {
    final bedtimeAlarm = _getBedtimeAlarm();
    final wakeAlarms = _getWakeUpAlarms();
    
    if (bedtimeAlarm == null || wakeAlarms.isEmpty) {
      return 0;
    }
    
    // Use the earliest wake-up alarm
    final earliestWakeAlarm = wakeAlarms.reduce((a, b) => 
        a.alarmTime.isBefore(b.alarmTime) ? a : b);
    
    // Calculate duration (handle next day case)
    DateTime bedtime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day,
    );
    
    DateTime wakeTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day,
      earliestWakeAlarm.alarmTime.hour, earliestWakeAlarm.alarmTime.minute
    );
    
    // If wake time is before bedtime, it's the next day
    if (wakeTime.isBefore(bedtime)) {
      wakeTime = wakeTime.add(const Duration(days: 1));
    }
    
    return wakeTime.difference(bedtime).inMinutes;
  }

  // Get real sleep duration for progress bar
  Map<String, dynamic> get _sleepDurationData {
    final sleepDuration = _calculateSleepDurationFromAlarms();
    
    if (sleepDuration > 0) {
      final hours = sleepDuration ~/ 60;
      final minutes = sleepDuration % 60;
      final totalMinutes = hours * 60 + minutes;
      
      // Calculate progress ratio (8 hours = 480 minutes is ideal)
      final idealSleep = 480; // 8 hours in minutes
      final ratio = (totalMinutes / idealSleep).clamp(0.0, 1.0);
      final percentage = (ratio * 100).round();
      
      return {
        'duration': "${hours}h ${minutes}m",
        'ratio': ratio,
        'percentage': percentage,
        'text': totalMinutes >= idealSleep 
            ? "You will get ${hours}h ${minutes}m for tonight"
            : "You will get ${hours}h ${minutes}m for tonight",
      };
    }
    
    // Default when no alarms
    return {
      'duration': "0h 0m",
      'ratio': 0.0,
      'percentage': 0,
      'text': "No sleep schedule found",
    };
  }

  AlarmModel? _getBedtimeAlarm() {
    for (final alarm in _userAlarms) {
      if (alarm.title.toLowerCase().contains('bedtime') || 
          alarm.title.toLowerCase().contains('sleep') ||
          alarm.title.toLowerCase().contains('نوم')) {
        return alarm;
      }
    }
    return null;
  }

  List<AlarmModel> _getWakeUpAlarms() {
    return _userAlarms.where((alarm) => 
        alarm.title.toLowerCase().contains('alarm') || 
        alarm.title.toLowerCase().contains('wake') ||
        alarm.title.toLowerCase().contains('صحي') ||
        alarm.title.toLowerCase().contains('استيقاظ')).toList();
  }

  List<int> showingTooltipOnSpots = [4];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    _loadSleepData();
    _loadUserAlarms();
    _initializeAlarms();
  }

  Future<void> _initializeAlarms() async {
    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId != null) {
        // Reschedule all active alarms for the user
        await AlarmService.rescheduleAllUserAlarms(userId);
      }
    } catch (e) {
      // Handle initialization error
    }
  }

  Future<void> _loadSleepData() async {
    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId != null) {
        final sleepData = await FitnessDataService.getLatestSleep(userId);
        if (sleepData != null) {
          setState(() {
            _latestSleep = SleepModel.fromJson(sleepData);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error loading sleep data
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSleepDataForDate(DateTime date) async {
    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId != null) {
        final client = SupabaseService.client;
        final response = await client
            .from('sleep_tracking')
            .select()
            .eq('user_id', userId)
            .eq('date', date.toIso8601String().split('T')[0])
            .single();
        
        setState(() {
          _latestSleep = SleepModel.fromJson(response);
        });
            }
    } catch (e) {
      // Handle error loading sleep data for date
      setState(() {
        _latestSleep = null;
      });
    }
  }

  Future<void> _loadUserAlarms() async {
    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId != null) {
        final alarms = await AlarmService.getUserAlarms(userId);
        setState(() {
          _userAlarms = alarms;
        });
        
        // Reschedule all alarms after loading to ensure they're up-to-date
        await AlarmService.rescheduleAllUserAlarms(userId);
      } else {
        print('No user ID found'); // Debug log
        setState(() {
          _userAlarms = [];
        });
      }
    } catch (e) {
      print('Error in _loadUserAlarms: $e'); // Debug log
      // Handle error loading alarms
      setState(() {
        _userAlarms = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: TColor.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
          "Sleep Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {
              _loadUserAlarms(); // Refresh alarms and sleep duration
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(20),
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          TColor.primaryColor2.withValues(alpha: 0.4),
                          TColor.primaryColor1.withValues(alpha: 0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _latestSleep != null ? "Last Night Sleep" : "Ideal Hours for Sleep",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 11,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _latestSleep?.durationFormatted ?? "8hours 30minutes",
                                      style: TextStyle(
                                          color: TColor.primaryColor2,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(minWidth: 90),
                                      height: 30,
                                      child: RoundButton(
                                          title: "Learn More",
                                          fontSize: 7,
                                        onPressed: () {},
                                      ),
                                    )
                                  ],
                                )
                              ]
                            ),
                        ),
                        Image.asset(
                          "assets/img/sleep_schedule.png",
                          width: media.width * 0.35,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    "Your Schedule",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                CalendarAgenda(
                  controller: _calendarAgendaControllerAppBar,
                  appbar: false,
                  selectedDayPosition: SelectedDayPosition.center,
                  leading: IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/img/ArrowLeft.png",
                        width: 15,
                        height: 15,
                      )),
                  training: IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/img/ArrowRight.png",
                        width: 15,
                        height: 15,
                      )),
                  weekDay: WeekDay.short,
                  dayNameFontSize: 12,
                  dayNumberFontSize: 16,
                  dayBGColor: Colors.grey.withOpacity(0.15),
                  titleSpaceBetween: 15,
                  backgroundColor: Colors.transparent,
                  // fullCalendar: false,
                  fullCalendarScroll: FullCalendarScroll.horizontal,
                  fullCalendarDay: WeekDay.short,
                  selectedDateColor: Colors.white,
                  dateColor: Colors.black,
                  locale: 'en',

                  initialDate: DateTime.now(),
                  calendarEventColor: TColor.primaryColor2,
                  firstDate: DateTime.now().subtract(const Duration(days: 140)),
                  lastDate: DateTime.now().add(const Duration(days: 60)),

                  onDateSelected: (date) {
                    setState(() {
                      _selectedDateAppBBar = date;
                    });
                    _loadSleepDataForDate(date);
                  },
                  selectedDayLogo: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: TColor.primaryG,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                Container(
                    width: double.maxFinite,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          TColor.secondaryColor2.withValues(alpha: 0.4),
                          TColor.secondaryColor1.withValues(alpha: 0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _latestSleep != null 
                              ? "You slept ${_latestSleep!.durationFormatted} last night"
                              : _sleepDurationData['text'],
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 12,
                          ),
                        ),
                        if (_latestSleep != null && _latestSleep!.qualityScore != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Sleep quality: ${_latestSleep!.qualityScore}/10",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 15,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SimpleAnimationProgressBar(
                              height: 15,
                              width: media.width - 80,
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.purple,
                              ratio: _sleepDurationData['ratio'],
                              direction: Axis.horizontal,
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: const Duration(seconds: 3),
                              borderRadius: BorderRadius.circular(7.5),
                              gradientColor: LinearGradient(
                                  colors: TColor.secondaryG,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight),
                            ),
                            Text(
                              "${_sleepDurationData['percentage']}%",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
                SizedBox(
                  height: media.width * 0.05,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SleepAddAlarmView(
                date: _selectedDateAppBBar,
              ),
            ),
          );
          
          // Refresh alarms if a new alarm was created
          if (result == true) {
            _loadUserAlarms();
          }
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}
