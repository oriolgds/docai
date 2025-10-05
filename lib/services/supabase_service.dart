import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

class SupabaseService {
  static bool _initialized = false;
  
  // Constants for better configuration
  static const String _emailRedirectUrl = 'docai://email-verified';
  static const String _authRedirectUrl = 'docai://auth';
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

  /// Enhanced sign-up with retry mechanism and proper redirect URLs
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

  /// Enhanced email resend with retry mechanism and consistent URLs
  static Future<void> resendVerificationEmail(String email) async {
    AuthException? lastError;
    
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        await client.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: _emailRedirectUrl,
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

  /// Force refresh user session and return updated user
  static Future<User?> refreshUserSession() async {
    try {
      final response = await client.auth.refreshSession();
      return response.user;
    } on AuthException catch (e) {
      // If refresh fails, the session might be invalid
      if (e.message.toLowerCase().contains('session_not_found') ||
          e.message.toLowerCase().contains('invalid_token') ||
          e.message.toLowerCase().contains('refresh_token_not_found')) {
        // Session is invalid, user needs to log in again
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
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

  /// Enhanced Google Sign-In with better error handling and redirect URL
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

  /// Get auth redirect URLs for configuration
  static String get emailRedirectUrl => _emailRedirectUrl;
  static String get authRedirectUrl => _authRedirectUrl;

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
           !message.contains('email_address_invalid') &&
           !message.contains('user_not_found') &&
           !message.contains('invalid_credentials');
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
    } else if (message.contains('user_not_found')) {
      return Exception('No account found with this email address.');
    } else if (message.contains('session_not_found') || message.contains('invalid_token')) {
      return Exception('Session expired. Please sign in again.');
    } else if (message.contains('network') || message.contains('timeout')) {
      return Exception('Network error. Please check your connection and try again.');
    } else {
      return Exception('Authentication failed: ${error.message}');
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

  // ==== ACCOUNT DELETION METHODS ====
  
  /// Comprehensive account deletion - removes all user data and account
  static Future<void> deleteUserAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final userId = user.id;
    final userEmail = user.email;

    // Step 1: Clear conversations (best effort)
    try {
      await clearAllConversations();
    } catch (e) {
      print('Warning: Error clearing conversations before account deletion: $e');
    }

    // Step 2: Remove data from auxiliary tables (best effort)
    await _deleteUserPreferences(userId);
    await _deleteUserSubscriptions(userId);
    await _deleteUserStats(userId);
    await _deleteUserMetadata(userId);

    // Step 3: Invoke edge function to remove auth user and remaining data
    final response = await client.functions.invoke('delete-user');

    if (response.status >= 400) {
      throw Exception('Failed to delete account. Status code: ${response.status}');
    }

    final responseData = response.data;
    if (responseData is Map) {
      final successValue = responseData['success'];
      final isSuccess = successValue == true || successValue == 'true';
      if (!isSuccess) {
        final errorMessage = (responseData['error'] ?? responseData['message'] ??
                'Edge function reported a failure while deleting the account')
            .toString();
        throw Exception(errorMessage);
      }
    }

    // Step 4: Clear local storage and cached data
    if (userEmail != null) {
      await _clearLocalUserData(userEmail);
    }

    // Step 5: Sign out (this will clear the session)
    await signOut();
  }

  /// Delete user preferences data
  static Future<void> _deleteUserPreferences(String userId) async {
    try {
      await client
          .from('user_medical_preferences')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('Warning: Error deleting user preferences data: $e');
      // Don't throw - continue with deletion process
    }
  }
  
  /// Delete user subscription data
  static Future<void> _deleteUserSubscriptions(String userId) async {
    try {
      await client
          .from('subscriptions')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('Warning: Error deleting user subscriptions: $e');
      // Don't throw - continue with deletion process
    }
  }
  
  /// Delete user statistics and analytics data
  static Future<void> _deleteUserStats(String userId) async {
    try {
      await client
          .from('user_stats')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('Warning: Error deleting user stats: $e');
      // Don't throw - continue with deletion process
    }
  }
  
  /// Delete any additional user metadata tables
  static Future<void> _deleteUserMetadata(String userId) async {
    try {
      // Delete from any other user-related tables
      // Add more tables here as needed

      // Delete user API keys
      await client
          .from('user_api_keys')
          .delete()
          .eq('user_id', userId);

      // Example: Delete user feedback
      await client
          .from('user_feedback')
          .delete()
          .eq('user_id', userId);

      // Example: Delete user activities
      await client
          .from('user_activities')
          .delete()
          .eq('user_id', userId);

    } catch (e) {
      print('Warning: Error deleting user metadata: $e');
      // Don't throw - continue with deletion process
    }
  }
  
  /// Clear all local user data from SharedPreferences
  static Future<void> _clearLocalUserData(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear verification-related data
      await prefs.remove('pending_verification_$userEmail');
      await prefs.remove('last_verification_$userEmail');
      
      // Clear any other user-specific local data
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.contains(userEmail) || key.contains('user_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Warning: Error clearing local user data: $e');
      // Don't throw - continue with deletion process
    }
  }
  
  /// Check if user has any subscription that needs to be cancelled
  static Future<bool> hasActiveSubscription() async {
    final user = currentUser;
    if (user == null) return false;
    
    try {
      final subscriptions = await client
          .from('subscriptions')
          .select('*')
          .eq('user_id', user.id)
          .eq('status', 'active');
          
      return subscriptions.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Get a summary of data that will be deleted
  static Future<Map<String, int>> getDataDeletionSummary() async {
    final user = currentUser;
    if (user == null) return {};

    final summary = <String, int>{};

    try {
      // Count conversations
      final conversations = await client
          .from('chat_conversations')
          .select('id')
          .eq('user_id', user.id);
      summary['conversations'] = conversations.length;

      // Count messages
      int totalMessages = 0;
      for (final conv in conversations) {
        final messages = await client
            .from('chat_messages')
            .select('id')
            .eq('conversation_id', conv['id']);
        totalMessages += messages.length;
      }
      summary['messages'] = totalMessages;

      // Count preferences
      final preferences = await client
          .from('user_preferences')
          .select('id')
          .eq('user_id', user.id);
      summary['preferences'] = preferences.length;

      // Count subscriptions
      final subscriptions = await client
          .from('subscriptions')
          .select('id')
          .eq('user_id', user.id);
      summary['subscriptions'] = subscriptions.length;

    } catch (e) {
      print('Error getting deletion summary: $e');
    }

    return summary;
  }

  // ==== BYOK API KEYS METHODS ====

  /// Get user's API key for a specific provider (decrypted)
  static Future<String?> getUserApiKey(String provider) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // First, get the encrypted API key from the database
      final result = await client
          .from('user_api_keys')
          .select('api_key')
          .eq('user_id', user.id)
          .eq('provider', provider)
          .maybeSingle(); // Use maybeSingle to avoid throwing if no record found

      // If no API key found, return null
      if (result == null || result['api_key'] == null) {
        return null;
      }

      final encryptedKey = result['api_key'] as String;

      // Now decrypt the API key using the RPC function
      final decryptedKey = await client
          .rpc('decrypt_api_key', params: {
            'encrypted_key': encryptedKey
          });

      return decryptedKey as String?;
    } catch (e) {
      // Key not found or decryption failed
      print('Error getting API key for provider $provider: $e');
      return null;
    }
  }

  /// Set user's API key for a specific provider (encrypted)
  static Future<void> setUserApiKey(String provider, String apiKey) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // First encrypt the API key
      final encryptedKey = await client.rpc('encrypt_api_key', params: {'plain_key': apiKey});

      // Then store it in the database
      await client
          .from('user_api_keys')
          .upsert({
            'user_id': user.id,
            'provider': provider,
            'api_key': encryptedKey,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Error saving API key: $e');
    }
  }

  /// Delete user's API key for a specific provider
  static Future<void> deleteUserApiKey(String provider) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await client
          .from('user_api_keys')
          .delete()
          .eq('user_id', user.id)
          .eq('provider', provider);
    } catch (e) {
      throw Exception('Error deleting API key: $e');
    }
  }

  /// Check if user has an API key for a specific provider
  static Future<bool> hasUserApiKey(String provider) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final result = await client
          .from('user_api_keys')
          .select('user_id')
          .eq('user_id', user.id)
          .eq('provider', provider)
          .maybeSingle(); // Use maybeSingle instead of single to avoid throwing

      return result != null;
    } catch (e) {
      print('Error checking API key for provider $provider: $e');
      return false;
    }
  }

  /// Get all user's API keys (without decrypting, for management)
  static Future<List<Map<String, dynamic>>> getUserApiKeys() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final result = await client
          .from('user_api_keys')
          .select('provider, created_at, updated_at')
          .eq('user_id', user.id);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error getting user API keys: $e');
      return [];
    }
  }
}