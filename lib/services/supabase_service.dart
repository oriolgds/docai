import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_preferences.dart';

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

  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false;
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null || idToken == null) {
        throw 'Authentication tokens not found';
      }
      
      await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  
  static bool get isSignedIn => currentUser != null;

  // User Preferences methods
  static Future<UserPreferences?> getUserPreferences() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await client
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return UserPreferences.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<UserPreferences> createUserPreferences(UserPreferences preferences) async {
    final response = await client
        .from('user_preferences')
        .insert(preferences.toJson())
        .select()
        .single();

    return UserPreferences.fromJson(response);
  }

  static Future<UserPreferences> updateUserPreferences(UserPreferences preferences) async {
    final response = await client
        .from('user_preferences')
        .update(preferences.toJson())
        .eq('user_id', preferences.userId)
        .select()
        .single();

    return UserPreferences.fromJson(response);
  }

  static Future<UserPreferences> upsertUserPreferences(UserPreferences preferences) async {
    final existing = await getUserPreferences();
    if (existing == null) {
      return await createUserPreferences(preferences);
    } else {
      return await updateUserPreferences(preferences.copyWith(id: existing.id));
    }
  }

  static Future<bool> isFirstTimeUser() async {
    final preferences = await getUserPreferences();
    return preferences?.isFirstTime ?? true;
  }

  static Future<void> markAsNotFirstTime() async {
    final user = currentUser;
    if (user == null) return;

    final existing = await getUserPreferences();
    if (existing != null) {
      await updateUserPreferences(existing.copyWith(isFirstTime: false));
    } else {
      await createUserPreferences(UserPreferences(
        userId: user.id,
        isFirstTime: false,
      ));
    }
  }
}