import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alarm_model.dart';
import '../models/sleep_model.dart';
import 'alarm_notification_service.dart';
import 'supabase_service.dart';
import 'fitness_data_service.dart';

class AlarmService {
  static final _client = Supabase.instance.client;

  // Calculate sleep duration between bedtime alarm and wake time alarm
  static int calculateSleepDuration(DateTime bedtime, DateTime wakeTime) {
    // If wake time is earlier than bedtime, it means sleep spans to next day
    DateTime adjustedWakeTime = wakeTime;
    if (wakeTime.isBefore(bedtime)) {
      adjustedWakeTime = wakeTime.add(const Duration(days: 1));
    }
    
    final duration = adjustedWakeTime.difference(bedtime);
    return duration.inMinutes;
  }

  // Auto-create sleep record from alarm times
  static Future<SleepModel?> createSleepRecordFromAlarms(String userId) async {
    try {
      // Get user's alarms
      final alarms = await getUserAlarms(userId);
      
      // Find bedtime and wake time alarms
      AlarmModel? bedtimeAlarm;
      AlarmModel? wakeTimeAlarm;
      
      for (final alarm in alarms) {
        if (alarm.title.toLowerCase().contains('bedtime') || 
            alarm.title.toLowerCase().contains('sleep')) {
          bedtimeAlarm = alarm;
        } else if (alarm.title.toLowerCase().contains('alarm') || 
                   alarm.title.toLowerCase().contains('wake')) {
          wakeTimeAlarm = alarm;
        }
      }
      
      if (bedtimeAlarm == null || wakeTimeAlarm == null) {
        print('No bedtime or wake time alarms found');
        return null;
      }
      
      // Calculate sleep duration
      final today = DateTime.now();
      final bedtime = DateTime(today.year, today.month, today.day, 
                               bedtimeAlarm.alarmTime.hour, bedtimeAlarm.alarmTime.minute);
      final wakeTime = DateTime(today.year, today.month, today.day, 
                               wakeTimeAlarm.alarmTime.hour, wakeTimeAlarm.alarmTime.minute);
      
      final durationMinutes = calculateSleepDuration(bedtime, wakeTime);
      
      // Create sleep record
      final sleepRecord = SleepModel(
        userId: userId,
        date: today,
        bedtime: bedtime,
        wakeTime: wakeTime,
        durationMinutes: durationMinutes,
        qualityScore: calculateSleepQuality(durationMinutes),
        createdAt: DateTime.now(),
      );
      
      return await FitnessDataService.createSleepRecord(sleepRecord);
    } catch (e) {
      print('Error creating sleep record from alarms: $e');
      return null;
    }
  }

  // Calculate sleep quality based on duration (7-9 hours = optimal)
  static int calculateSleepQuality(int durationMinutes) {
    final hours = durationMinutes / 60.0;
    
    if (hours >= 7 && hours <= 9) {
      return 9; // Optimal
    } else if (hours >= 6 && hours < 7) {
      return 7; // Good
    } else if (hours >= 5 && hours < 6) {
      return 5; // Fair
    } else if (hours >= 4 && hours < 5) {
      return 3; // Poor
    } else {
      return 1; // Very Poor
    }
  }

  static Future<List<AlarmModel>> getUserAlarms(String userId) async {
    try {
      print('Loading alarms for user: $userId'); // Debug log
      final response = await _client
          .from('sleep_alarms')
          .select()
          .eq('user_id', userId)
          .order('alarm_time', ascending: true);

      print('Found ${response.length} alarms'); // Debug log
      return response.map((json) => AlarmModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading alarms: $e'); // Debug log
      // Handle error loading alarms
      return [];
    }
  }

  static Future<AlarmModel?> getAlarmById(String alarmId) async {
    try {
      final response = await _client
          .from('sleep_alarms')
          .select()
          .eq('id', alarmId)
          .single();

      return AlarmModel.fromJson(response);
    } catch (e) {
      // Handle error loading alarm
      return null;
    }
  }

  static Future<AlarmModel?> createAlarm(AlarmModel alarm) async {
    try {
      print('Creating alarm: ${alarm.toJson()}'); // Debug log
      
      // First ensure user profile exists
      final userId = alarm.userId;
      final profileExists = await _ensureUserProfileExists(userId);
      if (!profileExists) {
        print('Failed to create or find user profile for: $userId');
        return null;
      }
      
      final response = await _client
          .from('sleep_alarms')
          .insert(alarm.toJson())
          .select()
          .single();

      final createdAlarm = AlarmModel.fromJson(response);
      print('Alarm created successfully: ${createdAlarm.id}'); // Debug log
      
      // Note: Scheduling is handled by _initializeAlarms() in SleepScheduleView
      // to avoid duplicate scheduling
      
      // Auto-calculate and create sleep record
      await _updateSleepRecordFromAlarms(userId);

      return createdAlarm;
    } catch (e) {
      print('Error creating alarm: $e'); // Debug log
      // Handle error creating alarm
      return null;
    }
  }

  static Future<bool> _ensureUserProfileExists(String userId) async {
    try {
      // Check if profile exists
      final existingProfile = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      
      if (existingProfile != null) {
        print('Profile already exists for user: $userId');
        return true;
      }
      
      // Get user data from auth
      final user = _client.auth.currentUser;
      if (user == null || user.id != userId) {
        print('User not found in auth or ID mismatch');
        return false;
      }
      
      // Use SupabaseService to create profile (handles RLS properly)
      print('Creating profile for user: $userId');
      final email = user.email;
      final username = email?.split('@')[0] ?? 'user_${userId.substring(0, 8)}';
      final fullName = user.userMetadata?['full_name'] ?? 'User';
      
      final success = await SupabaseService.createUserProfile(
        userId: userId,
        username: username,
        fullName: fullName,
        email: email,
      );
      
      if (success) {
        print('Profile created successfully for user: $userId');
        return true;
      } else {
        print('Failed to create profile for user: $userId');
        return false;
      }
    } catch (e) {
      print('Error ensuring profile exists: $e');
      return false;
    }
  }

  static Future<bool> updateAlarm(AlarmModel alarm) async {
    try {
      await _client
          .from('sleep_alarms')
          .update(alarm.toJson())
          .eq('id', alarm.id!);

      // Note: Scheduling is handled by _initializeAlarms() in SleepScheduleView
      // to avoid duplicate scheduling

      // Auto-calculate and update sleep record
      await _updateSleepRecordFromAlarms(alarm.userId);

      return true;
    } catch (e) {
      // Handle error updating alarm
      return false;
    }
  }

  // Helper method to update sleep record from alarms
  static Future<void> _updateSleepRecordFromAlarms(String userId) async {
    try {
      final sleepRecord = await createSleepRecordFromAlarms(userId);
      if (sleepRecord != null) {
        print('Sleep record updated from alarms: ${sleepRecord.durationMinutes} minutes');
      }
    } catch (e) {
      print('Error updating sleep record from alarms: $e');
    }
  }

  static Future<bool> deleteAlarm(String alarmId) async {
    try {
      // Get alarm info before deletion for userId
      final alarm = await getAlarmById(alarmId);
      
      await _client
          .from('sleep_alarms')
          .delete()
          .eq('id', alarmId);

      // Cancel notification for the deleted alarm
      await AlarmNotificationService.cancelAlarm(alarmId);

      // Auto-calculate and update sleep record if we have userId
      if (alarm != null) {
        await _updateSleepRecordFromAlarms(alarm.userId);
      }

      return true;
    } catch (e) {
      // Handle error deleting alarm
      return false;
    }
  }

  static Future<List<AlarmModel>> getActiveAlarmsForToday(String userId) async {
    try {
      final alarms = await getUserAlarms(userId);
      final now = DateTime.now();
      final todayAlarms = <AlarmModel>[];

      for (final alarm in alarms) {
        if (!alarm.isEnabled) continue;
        
        // Check if alarm should ring today
        if (alarm.shouldRingToday) {
          // Check if alarm time is in the future
          final alarmDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            alarm.alarmTime.hour,
            alarm.alarmTime.minute,
          );

          if (alarmDateTime.isAfter(now)) {
            todayAlarms.add(alarm);
          }
        }
      }

      return todayAlarms;
    } catch (e) {
      // Handle error loading active alarms
      return [];
    }
  }

  static Future<void> rescheduleAllUserAlarms(String userId) async {
    try {
      final alarms = await getUserAlarms(userId);
      await AlarmNotificationService.rescheduleAllAlarms(alarms);
    } catch (e) {
      // Handle error rescheduling alarms
    }
  }

  static Future<bool> toggleAlarm(String alarmId, bool isEnabled) async {
    try {
      final alarm = await getAlarmById(alarmId);
      if (alarm != null) {
        final updatedAlarm = AlarmModel(
          id: alarm.id,
          userId: alarm.userId,
          alarmTime: alarm.alarmTime,
          title: alarm.title,
          isEnabled: isEnabled,
          vibrate: alarm.vibrate,
          repeatDays: alarm.repeatDays,
          sound: alarm.sound,
          createdAt: alarm.createdAt,
        );
        return await updateAlarm(updatedAlarm);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}