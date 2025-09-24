import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_preferences.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

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