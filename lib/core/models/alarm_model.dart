class AlarmModel {
  final String? id;
  final String userId;
  final DateTime alarmTime;
  final String title;
  final bool isEnabled;
  final bool vibrate;
  final String? repeatDays;
  final String? sound;
  final DateTime createdAt;

  AlarmModel({
    this.id,
    required this.userId,
    required this.alarmTime,
    this.title = 'Alarm',
    this.isEnabled = true,
    this.vibrate = true,
    this.repeatDays,
    this.sound,
    required this.createdAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    try {
      return AlarmModel(
        id: json['id'],
        userId: json['user_id'],
        alarmTime: _parseDateTime(json['alarm_time']),
        title: json['title'] ?? 'Alarm',
        isEnabled: json['is_enabled'] ?? true,
        vibrate: json['vibrate'] ?? true,
        repeatDays: json['repeat_days'],
        sound: json['sound'],
        createdAt: _parseDateTime(json['created_at']),
      );
    } catch (e) {
      print('Error parsing AlarmModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateTimeValue) {
    if (dateTimeValue == null) {
      return DateTime.now();
    }
    
    if (dateTimeValue is DateTime) {
      return dateTimeValue;
    }
    
    if (dateTimeValue is String) {
      try {
        // Try parsing as ISO8601 first
        return DateTime.parse(dateTimeValue);
      } catch (e) {
        try {
          // Try parsing as other common formats
          final formats = [
            'HH:mm:ss',      // 12:25:30
            'HH:mm',         // 12:25
            'yyyy-MM-dd HH:mm:ss',
            'yyyy-MM-dd HH:mm',
          ];
          
          for (final format in formats) {
            try {
              // Simple parsing for time strings
              if (dateTimeValue.contains(':')) {
                final parts = dateTimeValue.split(':');
                if (parts.length >= 2) {
                  final hour = int.parse(parts[0]);
                  final minute = int.parse(parts[1]);
                  final now = DateTime.now();
                  return DateTime(now.year, now.month, now.day, hour, minute);
                }
              }
            } catch (e) {
              continue;
            }
          }
          
          // If all else fails, return current time
          print('Could not parse date time: $dateTimeValue, using current time');
          return DateTime.now();
        } catch (e) {
          print('Error parsing date time string: $dateTimeValue, error: $e');
          return DateTime.now();
        }
      }
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final json = {
      'user_id': userId,
      'alarm_time': alarmTime.toIso8601String(),
      'title': title,
      'is_enabled': isEnabled,
      'vibrate': vibrate,
      'repeat_days': repeatDays,
      'sound': sound,
      'created_at': createdAt.toIso8601String(),
    };
    
    // Only include ID if it's not null (for existing alarms)
    if (id != null) {
      json['id'] = id;
    }
    
    return json;
  }

  String get timeFormatted {
    return '${alarmTime.hour.toString().padLeft(2, '0')}:${alarmTime.minute.toString().padLeft(2, '0')}';
  }

  String get repeatDaysFormatted {
    if (repeatDays == null || repeatDays!.isEmpty) {
      return 'Once';
    }
    return repeatDays!;
  }

  bool get shouldRingToday {
    if (repeatDays == null || repeatDays!.isEmpty) {
      return alarmTime.isAfter(DateTime.now());
    }
    
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    
    // Check if today is in the repeat days
    if (repeatDays!.contains('Mon') && currentWeekday == 1) return true;
    if (repeatDays!.contains('Tue') && currentWeekday == 2) return true;
    if (repeatDays!.contains('Wed') && currentWeekday == 3) return true;
    if (repeatDays!.contains('Thu') && currentWeekday == 4) return true;
    if (repeatDays!.contains('Fri') && currentWeekday == 5) return true;
    if (repeatDays!.contains('Sat') && currentWeekday == 6) return true;
    if (repeatDays!.contains('Sun') && currentWeekday == 7) return true;
    
    return false;
  }
}