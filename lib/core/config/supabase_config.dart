import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://lmfuqdfozpgcwiqqxoeu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtZnVxZGZvenBnY3dpcXF4b2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NzA5MDEsImV4cCI6MjA3OTI0NjkwMX0.SSNZ87tIh_FPMk3gZF3AgL_penLBWwBcWT7kW2KKWKU';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}