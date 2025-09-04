import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static bool _initialized = false;
  
  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    
    await dotenv.load();
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase credentials not found in .env file');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    _initialized = true;
  }

  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'docai://email-verified',
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  
  static bool get isSignedIn => currentUser != null;
}