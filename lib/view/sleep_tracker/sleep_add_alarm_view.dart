import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';
import '../../core/models/alarm_model.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/supabase_service.dart';

class SleepAddAlarmView extends StatefulWidget {
  final DateTime date;
  const SleepAddAlarmView({super.key, required this.date});

  @override
  State<SleepAddAlarmView> createState() => _SleepAddAlarmViewState();
}

class _SleepAddAlarmViewState extends State<SleepAddAlarmView> {

  bool positive = false;
  DateTime _selectedTime = DateTime.now().add(const Duration(hours: 8));
  String _selectedRepeat = 'Once';
  final String _selectedSound = 'assets/sounds/alarm_sound.mp3';
  bool _isLoading = false;
  String _alarmType = 'Bedtime'; // New: Alarm type selection

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.primaryColor1,
              onPrimary: TColor.white,
              surface: TColor.white,
              onSurface: TColor.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectAlarmType() async {
    final List<String> alarmTypes = [
      'Bedtime',
      'Wake Up',
    ];
    
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alarm Type', style: TextStyle(color: TColor.black)),
          backgroundColor: TColor.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: alarmTypes.map((type) {
              return ListTile(
                leading: Icon(
                  type == 'Bedtime' ? Icons.bed : Icons.alarm,
                  color: TColor.primaryColor1,
                ),
                title: Text(type, style: TextStyle(color: TColor.black)),
                subtitle: Text(
                  type == 'Bedtime' ? 'Go to sleep reminder' : 'Wake up alarm',
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                onTap: () => Navigator.pop(context, type),
              );
            }).toList(),
          ),
        );
      },
    );
    
    if (selected != null) {
      setState(() {
        _alarmType = selected;
      });
    }
  }

  Future<void> _selectRepeatDays() async {
    final List<String> repeatOptions = [
      'Once',
      'Mon to Fri',
      'Every day',
      'Mon,Wed,Fri',
      'Weekends'
    ];
    
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Repeat Days', style: TextStyle(color: TColor.black)),
          backgroundColor: TColor.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: repeatOptions.map((option) {
              return ListTile(
                title: Text(option, style: TextStyle(color: TColor.black)),
                onTap: () => Navigator.pop(context, option),
              );
            }).toList(),
          ),
        );
      },
    );
    
    if (selected != null) {
      setState(() {
        _selectedRepeat = selected;
      });
    }
  }

  Future<void> _createAlarm() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      String? repeatDays;
      switch (_selectedRepeat) {
        case 'Mon to Fri':
          repeatDays = 'Mon,Tue,Wed,Thu,Fri';
          break;
        case 'Every day':
          repeatDays = 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';
          break;
        case 'Mon,Wed,Fri':
          repeatDays = 'Mon,Wed,Fri';
          break;
        case 'Weekends':
          repeatDays = 'Sat,Sun';
          break;
        default:
          repeatDays = null;
      }

      final newAlarm = AlarmModel(
        userId: userId,
        alarmTime: _selectedTime,
        title: _alarmType, // Use selected alarm type
        isEnabled: true,
        vibrate: positive,
        repeatDays: repeatDays,
        sound: _selectedSound,
        createdAt: DateTime.now(),
      );

      final createdAlarm = await AlarmService.createAlarm(newAlarm);
      
      if (createdAlarm != null) {
        Navigator.pop(context, true); // Return success
      } else {
        throw Exception('Failed to create alarm');
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create alarm: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          "Add Alarm",
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Alarm Type Selection
          IconTitleNextRow(
              icon: "assets/img/Bed_Add.png",
              title: "Alarm Type",
              time: _alarmType,
              color: TColor.lightGray,
              onPressed: _selectAlarmType),
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/img/Bed_Add.png",
              title: "Alarm Time",
              time: TimeOfDay.fromDateTime(_selectedTime).format(context),
              color: TColor.lightGray,
              onPressed: _selectTime),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/Repeat.png",
              title: "Repeat",
              time: _selectedRepeat,
              color: TColor.lightGray,
              onPressed: _selectRepeatDays),
          const SizedBox(
            height: 10,
          ),
         Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

               const SizedBox(width: 15,), 
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/img/Vibrate.png",
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Vibrate When Alarm Sound",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                ),
                

                SizedBox(
                  height: 30,
                  child: Transform.scale(
                    scale: 0.7,
                    child: CustomAnimatedToggleSwitch<bool>(
                      current: positive,
                      values: const [false, true],
                      dif: 0.0,
                      indicatorSize: const Size.square(30.0),
                      animationDuration: const Duration(milliseconds: 200),
                      animationCurve: Curves.linear,
                      onChanged: (b) => setState(() => positive = b),
                      iconBuilder: (context, local, global) {
                        return const SizedBox();
                      },
                      defaultCursor: SystemMouseCursors.click,
                      onTap: () => setState(() => positive = !positive),
                      iconsTappable: false,
                      wrapperBuilder: (context, global, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                                left: 10.0,
                                right: 10.0,
                                height: 30.0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: TColor.secondaryG),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0)),
                                  ),
                                )),
                            child,
                          ],
                        );
                      },
                      foregroundIndicatorBuilder: (context, global) {
                        return SizedBox.fromSize(
                          size: const Size(10, 10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50.0)),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black38,
                                    spreadRadius: 0.05,
                                    blurRadius: 1.1,
                                    offset: Offset(0.0, 0.8))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
               
              ],
            ),
          ),
          const Spacer(),
          RoundButton(
            title: _isLoading ? "Creating..." : "Add", 
            onPressed: _isLoading ? null : _createAlarm
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
