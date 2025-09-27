import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

class SupabaseService {
  static bool _initialized = false;
  
  // Constants for better configuration
  static const String _emailRedirectUrl = 'docai://email-verified';
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  
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
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    
    _initialized = true;
  }

  /// Enhanced sign-in with better error handling
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Clear any pending verification state on successful login
      if (response.user?.emailConfirmedAt != null) {
        await _clearPendingVerification(email);
      }
      
      return response;
    } on AuthException catch (e) {
      // Handle specific auth errors
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Network error. Please check your connection and try again.');
    }
  }

  /// Enhanced sign-up with retry mechanism
  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    AuthException? lastError;
    
    // Retry mechanism for better reliability
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        final response = await client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: _emailRedirectUrl,
        );
        
        // Store pending verification state
        await _storePendingVerification(email);
        
        return response;
      } on AuthException catch (e) {
        lastError = e;
        if (attempt < _maxRetryAttempts && _shouldRetry(e)) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw _handleAuthError(e);
      } catch (e) {
        if (attempt < _maxRetryAttempts) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw Exception('Network error. Please check your connection and try again.');
      }
    }
    
    // This should never be reached, but just in case
    throw _handleAuthError(lastError ?? AuthException('Unknown error'));
  }

  /// Enhanced email resend with retry mechanism
  static Future<void> resendVerificationEmail(String email) async {
    AuthException? lastError;
    
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        await client.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: _emailRedirectUrl, // Fixed: consistent URL scheme
        );
        
        // Update last sent timestamp
        await _updateVerificationTimestamp(email);
        return;
      } on AuthException catch (e) {
        lastError = e;
        if (attempt < _maxRetryAttempts && _shouldRetry(e)) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw _handleAuthError(e);
      } catch (e) {
        if (attempt < _maxRetryAttempts) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw Exception('Network error. Please check your connection and try again.');
      }
    }
    
    throw _handleAuthError(lastError ?? AuthException('Failed to resend verification email'));
  }

  /// Check if user has pending email verification
  static Future<bool> hasPendingVerification(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('pending_verification_$email');
  }

  /// Get time since last verification email was sent
  static Future<Duration?> getTimeSinceLastVerificationEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_verification_$email');
    if (timestamp == null) return null;
    
    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  /// Enhanced Google Sign-In with better error handling
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
        throw Exception('Google authentication tokens not found');
      }
      
      await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      return true;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      return false;
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      // Log error but don't throw - we want to clear local state anyway
      print('Warning: Error during sign out: $e');
    }
  }

  static User? get currentUser => client.auth.currentUser;
  
  static bool get isSignedIn => currentUser != null;
  
  /// Check if current user's email is verified
  static bool get isEmailVerified {
    final user = currentUser;
    return user?.emailConfirmedAt != null;
  }

  // Private helper methods
  static Future<void> _storePendingVerification(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_verification_$email', email);
    await prefs.setInt('last_verification_$email', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> _clearPendingVerification(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_verification_$email');
    await prefs.remove('last_verification_$email');
  }

  static Future<void> _updateVerificationTimestamp(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_verification_$email', DateTime.now().millisecondsSinceEpoch);
  }

  static bool _shouldRetry(AuthException error) {
    // Don't retry for user errors, only for potential network/server issues
    final message = error.message.toLowerCase();
    return !message.contains('invalid') && 
           !message.contains('already') &&
           !message.contains('weak_password') &&
           !message.contains('email_address_invalid');
  }

  static Exception _handleAuthError(AuthException error) {
    final message = error.message.toLowerCase();
    
    if (message.contains('invalid_credentials') || message.contains('invalid login credentials')) {
      return Exception('Invalid email or password. Please check your credentials.');
    } else if (message.contains('email_not_confirmed')) {
      return Exception('Please verify your email address before signing in.');
    } else if (message.contains('too_many_requests')) {
      return Exception('Too many attempts. Please wait a moment before trying again.');
    } else if (message.contains('weak_password')) {
      return Exception('Password is too weak. Please choose a stronger password.');
    } else if (message.contains('email_address_invalid')) {
      return Exception('Please enter a valid email address.');
    } else if (message.contains('user_already_exists') || message.contains('already')) {
      return Exception('An account with this email already exists. Please try signing in instead.');
    } else if (message.contains('network') || message.contains('timeout')) {
      return Exception('Network error. Please check your connection and try again.');
    } else {
      return Exception('Authentication failed: ${error.message}');
    }
  }

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

  // Chat History methods
  static Future<List<ChatConversation>> getUserConversations() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final conversationsData = await client
          .from('chat_conversations')
          .select()
          .eq('user_id', user.id)
          .order('updated_at', ascending: false);

      List<ChatConversation> conversations = [];
      
      for (final convData in conversationsData) {
        final conversation = ChatConversation.fromSupabaseJson(convData);
        
        // Cargar mensajes para esta conversación
        final messagesData = await client
            .from('chat_messages')
            .select()
            .eq('conversation_id', conversation.id)
            .order('created_at', ascending: true);
            
        final messages = messagesData
            .map((msgData) => ChatMessage.fromSupabaseJson(msgData))
            .toList();
            
        conversations.add(conversation.copyWith(messages: messages));
      }
      
      return conversations;
    } catch (e) {
      throw Exception('Error loading conversations: $e');
    }
  }

  static Future<void> saveConversation(ChatConversation conversation) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    try {
      // Upsert conversation
      await client
          .from('chat_conversations')
          .upsert(conversation.toSupabaseJson(user.id));
      
      // Delete existing messages for this conversation
      await client
          .from('chat_messages')
          .delete()
          .eq('conversation_id', conversation.id);
      
      // Insert new messages
      if (conversation.messages.isNotEmpty) {
        final messagesData = conversation.messages
            .map((msg) => msg.toSupabaseJson(conversation.id))
            .toList();
            
        await client
            .from('chat_messages')
            .insert(messagesData);
      }
      
    } catch (e) {
      throw Exception('Error saving conversation: $e');
    }
  }

  static Future<void> deleteConversation(String conversationId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    try {
      // Eliminar mensajes primero
      await client
          .from('chat_messages')
          .delete()
          .eq('conversation_id', conversationId);
      
      // Eliminar conversación
      await client
          .from('chat_conversations')
          .delete()
          .eq('id', conversationId)
          .eq('user_id', user.id);
          
    } catch (e) {
      throw Exception('Error deleting conversation: $e');
    }
  }

  static Future<void> clearAllConversations() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    try {
      // Obtener todas las conversaciones del usuario
      final conversations = await client
          .from('chat_conversations')
          .select('id')
          .eq('user_id', user.id);
      
      // Eliminar todos los mensajes del usuario
      for (final conv in conversations) {
        await client
            .from('chat_messages')
            .delete()
            .eq('conversation_id', conv['id']);
      }
      
      // Eliminar todas las conversaciones del usuario
      await client
          .from('chat_conversations')
          .delete()
          .eq('user_id', user.id);
          
    } catch (e) {
      throw Exception('Error clearing all conversations: $e');
    }
  }
}