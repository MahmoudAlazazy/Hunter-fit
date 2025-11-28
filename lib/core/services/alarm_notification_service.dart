import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_model.dart';

class AlarmNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Initialize notification settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel',
      'Sleep Alarms',
      description: 'Notifications for sleep alarms',
      importance: Importance.high,
      playSound: true,
      sound: UriAndroidNotificationSound('content://settings/system/notification_sound'), // Use system default alarm sound
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap - stop alarm
    if (response.payload != null) {
      _stopAlarmSound();
    }
  }

  // Control alarm sound and vibration
  static bool _isAlarmPlaying = false;
  static String? _currentAlarmId;

  static Future<void> _stopAlarmSound() async {
    try {
      await _notificationsPlugin.cancelAll(); // Stop notification sound
      _isAlarmPlaying = false;
      _currentAlarmId = null;
      print('Alarm sound stopped');
    } catch (e) {
      print('Error stopping alarm sound: $e');
    }
  }

  static Future<void> toggleAlarmSound() async {
    if (_isAlarmPlaying) {
      await _stopAlarmSound();
    } else {
      await _playAlarmSound();
    }
  }

  static Future<void> _playAlarmSound() async {
    try {
      // Show a persistent notification with sound and stop button
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'alarm_channel',
        'Sleep Alarms',
        channelDescription: 'Active alarm notification',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: UriAndroidNotificationSound('content://settings/system/alarm_alert'),
        ongoing: true,
        autoCancel: false,
        fullScreenIntent: true,
        actions: [
          AndroidNotificationAction('stop_alarm', 'Stop Alarm'),
        ],
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Alarm Ringing!',
        'Tap to stop or use the stop button',
        notificationDetails,
        payload: 'alarm_ringing',
      );

      _isAlarmPlaying = true;
      print('Alarm sound started');
    } catch (e) {
      print('Error playing alarm sound: $e');
    }
  }

  static bool get isAlarmPlaying => _isAlarmPlaying;

  // Handle notification actions (like stop button)
  static void _onNotificationAction(NotificationResponse response) {
    if (response.actionId == 'stop_alarm') {
      _stopAlarmSound();
      print('Alarm stopped via action button');
    } else if (response.payload == 'alarm_ringing') {
      _stopAlarmSound();
      print('Alarm stopped via notification tap');
    }
  }

  // Start alarm notification (can be called from anywhere)
  static Future<void> startAlarmNotification(String alarmTitle) async {
    _currentAlarmId = alarmTitle;
    await _playAlarmSound();
  }

  // Stop alarm notification (can be called from anywhere)
  static Future<void> stopAlarmNotification() async {
    await _stopAlarmSound();
  }

  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.alarmTime.hour,
      alarm.alarmTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Check if alarm should ring on this day
    if (alarm.repeatDays != null && alarm.repeatDays!.isNotEmpty) {
      final weekday = scheduledDate.weekday;
      final dayMap = {
        1: 'Mon',
        2: 'Tue', 
        3: 'Wed',
        4: 'Thu',
        5: 'Fri',
        6: 'Sat',
        7: 'Sun',
      };
      
      final dayName = dayMap[weekday];
      if (dayName != null && !alarm.repeatDays!.contains(dayName)) {
        return; // Don't schedule for this day
      }
    }

    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    // Determine icon based on alarm type
    final isBedtimeAlarm = alarm.title.toLowerCase().contains('bedtime') || 
                         alarm.title.toLowerCase().contains('sleep') ||
                         alarm.title.toLowerCase().contains('نوم');
    final iconResource = isBedtimeAlarm ? 'ic_bed_notification' : 'ic_alarm_notification';

    try {
      // Try exact alarm first (requires permission)
      await _notificationsPlugin.zonedSchedule(
        alarm.id.hashCode, // Use alarm ID as notification ID
        alarm.title,
        'Time to wake up!',
        tzScheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel',
            'Sleep Alarms',
            channelDescription: 'Notifications for sleep alarms',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            sound: const UriAndroidNotificationSound('asset:///assets/sounds/alarm_sound.mp3'), // Custom alarm sound
            enableVibration: alarm.vibrate,
            ongoing: true,
            autoCancel: false,
            fullScreenIntent: true,
            icon: '@mipmap/ic_launcher', // Use app icon as fallback
            largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_alarm_large'), // Large icon
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: alarm.sound ?? 'default',
          ),
        ),
        payload: alarm.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: alarm.repeatDays != null && alarm.repeatDays!.isNotEmpty
            ? DateTimeComponents.time
            : null,
      );
      print('Alarm scheduled with exact timing: ${alarm.title}');
    } catch (e) {
      // Fallback to inexact alarm if exact permission denied
      print('Exact alarm not permitted, using inexact alarm: $e');
      try {
        await _notificationsPlugin.zonedSchedule(
          alarm.id.hashCode,
          alarm.title,
          'Time to wake up!',
          tzScheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'alarm_channel',
              'Sleep Alarms',
              channelDescription: 'Notifications for sleep alarms',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              sound: const UriAndroidNotificationSound('asset:///assets/sounds/alarm_sound.mp3'), // Custom alarm sound
              enableVibration: alarm.vibrate,
              ongoing: true,
              autoCancel: false,
              fullScreenIntent: true,
              icon: '@mipmap/ic_launcher', // Use app icon as fallback
              largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_alarm_large'), // Large icon
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: alarm.sound ?? 'default',
            ),
          ),
          payload: alarm.id,
          androidScheduleMode: AndroidScheduleMode.inexact, // Fallback mode
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: alarm.repeatDays != null && alarm.repeatDays!.isNotEmpty
              ? DateTimeComponents.time
              : null,
        );
        print('Alarm scheduled with inexact timing: ${alarm.title}');
      } catch (fallbackError) {
        print('Failed to schedule alarm completely: $fallbackError');
      }
    }
  }

  static Future<void> cancelAlarm(String alarmId) async {
    await _notificationsPlugin.cancel(alarmId.hashCode);
  }

  static Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> rescheduleAllAlarms(List<AlarmModel> alarms) async {
    await cancelAllAlarms();
    
    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await scheduleAlarm(alarm);
      }
    }
  }

  static Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      999,
      'Test Alarm',
      'This is a test notification',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Sleep Alarms',
          channelDescription: 'Notifications for sleep alarms',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_sound'),
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}