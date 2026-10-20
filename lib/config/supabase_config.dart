import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://aoblrjyqmdouupwqhpfx.supabase.co';
  static const String anonKey = 'https://aoblrjyqmdouupwqhpfx.supabase.co/rest/v1/';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}