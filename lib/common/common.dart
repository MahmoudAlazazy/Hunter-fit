import 'package:intl/intl.dart';

String getTime(int value, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(
      DateTime.fromMillisecondsSinceEpoch(value * 60 * 1000, isUtc: true));
}

String getStringDateToOtherFormate(String dateStr,
    {String inputFormatStr = "dd/MM/yyyy hh:mm aa",
    String outFormatStr = "hh:mm a"}) {
  var format = DateFormat(outFormatStr);
  return format.format(stringToDate(dateStr, formatStr: inputFormatStr));
}

DateTime stringToDate(String dateStr, {String formatStr = "hh:mm a"}) {
  try {
    // Handle time-only formats (like "12:00" or "12:25")
    if (dateStr.contains(':') && !dateStr.contains('/')) {
      final parts = dateStr.split(':');
      if (parts.length >= 2) {
        try {
          final hour = int.parse(parts[0]);
          final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, hour, minute);
        } catch (e) {
          print('Error parsing time string: $dateStr, error: $e');
        }
      }
    }
    
    // Try normal date parsing
    var format = DateFormat(formatStr);
    return format.parse(dateStr);
  } catch (e) {
    print('Error parsing date string: $dateStr with format: $formatStr, error: $e');
    // Return current time as fallback
    return DateTime.now();
  }
}

DateTime dateToStartDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateToString(DateTime date, {String formatStr = "dd/MM/yyyy hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(date);
}

String getDayTitle(String dateStr, {String formatStr = "dd/MM/yyyy hh:mm a"} ) {
  var date = stringToDate(dateStr, formatStr: formatStr);

  if (date.isToday) {
    return "Today";
  } else if (date.isTomorrow) {
    return "Tomorrow";
  } else if (date.isYesterday) {
    return "Yesterday";
  } else {
    var outFormat = DateFormat("E");
    return outFormat.format(date) ;
  }
}

extension DateHelpers on DateTime {
  bool get isToday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 0;
  }

  bool get isYesterday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == -1;
  }

  bool get isTomorrow {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 1;
  }
}
