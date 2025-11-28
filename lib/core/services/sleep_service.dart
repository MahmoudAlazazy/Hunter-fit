import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sleep_model.dart';

class SleepService {
  static final _client = Supabase.instance.client;

  static Future<List<SleepModel>> getUserSleepData(String userId, {int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days - 1));
      
      final response = await _client
          .from('sleep_tracking')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return response.map((json) => SleepModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching sleep data: $e');
      return [];
    }
  }

  static Future<SleepModel?> getSleepForDate(String userId, DateTime date) async {
    try {
      final response = await _client
          .from('sleep_tracking')
          .select()
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0])
          .single();

      return SleepModel.fromJson(response);
    } catch (e) {
      print('Error fetching sleep for date: $e');
      return null;
    }
  }

  static Future<SleepModel?> createSleepRecord(SleepModel sleep) async {
    try {
      final response = await _client
          .from('sleep_tracking')
          .insert(sleep.toJson())
          .select()
          .single();

      return SleepModel.fromJson(response);
    } catch (e) {
      print('Error creating sleep record: $e');
      return null;
    }
  }

  static Future<SleepModel?> updateSleepRecord(SleepModel sleep) async {
    try {
      final response = await _client
          .from('sleep_tracking')
          .update(sleep.toJson())
          .eq('id', sleep.id!)
          .select()
          .single();

      return SleepModel.fromJson(response);
    } catch (e) {
      print('Error updating sleep record: $e');
      return null;
    }
  }

  static Future<void> deleteSleepRecord(String sleepId) async {
    try {
      await _client
          .from('sleep_tracking')
          .delete()
          .eq('id', sleepId);
    } catch (e) {
      print('Error deleting sleep record: $e');
    }
  }

  static List<FlSpot> convertSleepDataToChartSpots(List<SleepModel> sleepData) {
    if (sleepData.isEmpty) {
      return const [
        FlSpot(1, 3),
        FlSpot(2, 5),
        FlSpot(3, 4),
        FlSpot(4, 7),
        FlSpot(5, 4),
        FlSpot(6, 8),
        FlSpot(7, 5),
      ];
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < sleepData.length; i++) {
      final sleep = sleepData[i];
      final hours = sleep.durationMinutes / 60.0;
      spots.add(FlSpot(i + 1, hours));
    }

    // Fill missing days with 0 if we have less than 7 days
    while (spots.length < 7) {
      spots.add(FlSpot(spots.length + 1, 0));
    }

    return spots;
  }
}