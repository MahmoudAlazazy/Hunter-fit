import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';
import '../common/common.dart';
import '../core/services/alarm_notification_service.dart';

class TodaySleepScheduleRow extends StatefulWidget {
  final Map sObj;
  final VoidCallback? onAlarmUpdated; // Add callback
  const TodaySleepScheduleRow({super.key, required this.sObj, this.onAlarmUpdated});

  @override
  State<TodaySleepScheduleRow> createState() => _TodaySleepScheduleRowState();
}

class _TodaySleepScheduleRowState extends State<TodaySleepScheduleRow> {
  bool positive = false;

  @override
  void initState() {
    super.initState();
    // Set initial state from alarm data
    positive = widget.sObj["isEnabled"] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                widget.sObj["image"].toString(),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.sObj["name"].toString(),
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        ", ${getStringDateToOtherFormate(widget.sObj["time"].toString())}",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8,),
                  Text(
                    widget.sObj["duration"].toString(),
                    style: TextStyle(
                        color: TColor.gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          _deleteAlarm();
                          break;
                        case 'edit':
                          _editAlarm();
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: TColor.gray),
                            const SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: TColor.black)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: TColor.gray,
                      size: 20,
                    ),
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
                      onChanged: (b) => _toggleAlarm(b),
                      iconBuilder: (context, local, global) {
                        return const SizedBox();
                      },
                      defaultCursor: SystemMouseCursors.click,
                      onTap: () => _toggleAlarm(!positive),
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
                ),
              ],
            )
          ],
        ));
  }

  void _toggleAlarm(bool isOn) {
    setState(() {
      positive = isOn;
    });

    if (isOn) {
      // Start alarm
      AlarmNotificationService.startAlarmNotification(widget.sObj["name"].toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm "${widget.sObj["name"]}" started'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Stop alarm
      AlarmNotificationService.stopAlarmNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm "${widget.sObj["name"]}" stopped'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteAlarm() {
    // Stop alarm if it's playing
    if (positive) {
      AlarmNotificationService.stopAlarmNotification();
    }
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Alarm'),
        content: Text('Are you sure you want to delete "${widget.sObj["name"]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: TColor.gray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Actually delete the alarm from database
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alarm "${widget.sObj["name"]}" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
              // Notify parent to refresh
              widget.onAlarmUpdated?.call();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editAlarm() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit feature coming soon for "${widget.sObj["name"]}"'),
        backgroundColor: TColor.primaryColor1,
      ),
    );
  }
}
