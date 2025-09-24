import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import 'supabase_service.dart';
import 'openrouter_service.dart';

class ChatHistoryService {
  static const String _localChatsKey = 'local_chats';
  static const String _cloudSyncEnabledKey = 'cloud_sync_enabled';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  // Singleton
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  SharedPreferences? _prefs;
  final OpenRouterService _openRouterService = OpenRouterService();
  
  // Cache para optimizar rendimiento
  List<ChatConversation>? _cachedLocalConversations;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidDuration = Duration(minutes: 1);
  
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Configuración de sincronización
  Future<bool> isCloudSyncEnabled() async {
    await _initPrefs();
    return _prefs!.getBool(_cloudSyncEnabledKey) ?? false;
  }

  Future<void> setCloudSyncEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs!.setBool(_cloudSyncEnabledKey, enabled);
    
    if (enabled) {
      // Si se habilita la sincronización, combinar chats locales con la nube
      await _syncLocalChatsToCloud();
    }
  }

  // Métodos de utilidad para cache
  bool _isCacheValid() {
    return _cachedLocalConversations != null && 
           _cacheTimestamp != null && 
           DateTime.now().difference(_cacheTimestamp!) < _cacheValidDuration;
  }

  void _invalidateCache() {
    _cachedLocalConversations = null;
    _cacheTimestamp = null;
  }

  // Gestión de conversaciones locales
  Future<List<ChatConversation>> getLocalConversations({bool forceRefresh = false}) async {
    // Usar cache si es válido y no se fuerza refresh
    if (!forceRefresh && _isCacheValid()) {
      return List.from(_cachedLocalConversations!);
    }

    try {
      await _initPrefs();
      final chatsJson = _prefs!.getStringList(_localChatsKey) ?? [];
      
      final conversations = chatsJson.map((chatJson) {
        try {
          final data = jsonDecode(chatJson) as Map<String, dynamic>;
          return ChatConversation.fromJson(data);
        } catch (e) {
          debugPrint('Error parsing conversation: $e');
          return null;
        }
      }).whereType<ChatConversation>().toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // Actualizar cache
      _cachedLocalConversations = conversations;
      _cacheTimestamp = DateTime.now();

      return List.from(conversations);
    } catch (e) {
      debugPrint('Error loading local conversations: $e');
      // Si hay error, devolver cache si existe, o lista vacía
      return _cachedLocalConversations != null 
          ? List.from(_cachedLocalConversations!) 
          : <ChatConversation>[];
    }
  }

  Future<void> saveLocalConversation(ChatConversation conversation) async {
    try {
      await _initPrefs();
      final conversations = await getLocalConversations(forceRefresh: true);
      
      // Buscar si ya existe la conversación
      final existingIndex = conversations.indexWhere((c) => c.id == conversation.id);
      
      if (existingIndex != -1) {
        conversations[existingIndex] = conversation;
      } else {
        conversations.add(conversation);
      }
      
      // Ordenar por fecha de actualización
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Guardar en SharedPreferences
      final chatsJson = conversations.map((c) {
        try {
          return jsonEncode(c.toJson());
        } catch (e) {
          debugPrint('Error encoding conversation ${c.id}: $e');
          return null;
        }
      }).whereType<String>().toList();
      
      await _prefs!.setStringList(_localChatsKey, chatsJson);
      
      // Invalidar cache para forzar recarga en la próxima consulta
      _invalidateCache();
      
    } catch (e) {
      debugPrint('Error saving local conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteLocalConversation(String conversationId) async {
    try {
      await _initPrefs();
      final conversations = await getLocalConversations(forceRefresh: true);
      final initialCount = conversations.length;
      
      conversations.removeWhere((c) => c.id == conversationId);
      
      // Solo guardar si realmente se eliminó algo
      if (conversations.length < initialCount) {
        final chatsJson = conversations.map((c) {
          try {
            return jsonEncode(c.toJson());
          } catch (e) {
            debugPrint('Error encoding conversation ${c.id}: $e');
            return null;
          }
        }).whereType<String>().toList();
        
        await _prefs!.setStringList(_localChatsKey, chatsJson);
        _invalidateCache();
      }
    } catch (e) {
      debugPrint('Error deleting local conversation: $e');
      rethrow;
    }
  }

  // Gestión de conversaciones en la nube
  Future<List<ChatConversation>> getCloudConversations() async {
    if (!SupabaseService.isSignedIn) return [];
    
    try {
      final conversationsData = await SupabaseService.client
          .from('chat_conversations')
          .select()
          .eq('user_id', SupabaseService.currentUser!.id)
          .order('updated_at', ascending: false);

      List<ChatConversation> conversations = [];
      
      for (final convData in conversationsData) {
        final conversation = ChatConversation.fromSupabaseJson(convData);
        
        // Cargar mensajes para esta conversación
        final messagesData = await SupabaseService.client
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
      debugPrint('Error loading cloud conversations: $e');
      return [];
    }
  }

  Future<void> saveCloudConversation(ChatConversation conversation) async {
    if (!SupabaseService.isSignedIn) return;
    
    try {
      final userId = SupabaseService.currentUser!.id;
      
      // Upsert conversation
      await SupabaseService.client
          .from('chat_conversations')
          .upsert(conversation.toSupabaseJson(userId));
      
      // Delete existing messages for this conversation
      await SupabaseService.client
          .from('chat_messages')
          .delete()
          .eq('conversation_id', conversation.id);
      
      // Insert new messages
      if (conversation.messages.isNotEmpty) {
        final messagesData = conversation.messages
            .map((msg) => msg.toSupabaseJson(conversation.id))
            .toList();
            
        await SupabaseService.client
            .from('chat_messages')
            .insert(messagesData);
      }
      
    } catch (e) {
      debugPrint('Error saving cloud conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteCloudConversation(String conversationId) async {
    if (!SupabaseService.isSignedIn) return;
    
    try {
      // Eliminar mensajes primero
      await SupabaseService.client
          .from('chat_messages')
          .delete()
          .eq('conversation_id', conversationId);
      
      // Eliminar conversación
      await SupabaseService.client
          .from('chat_conversations')
          .delete()
          .eq('id', conversationId);
          
    } catch (e) {
      debugPrint('Error deleting cloud conversation: $e');
      rethrow;
    }
  }

  // Métodos principales de la API
  Future<List<ChatConversation>> getAllConversations() async {
    final localConversations = await getLocalConversations();
    
    if (!await isCloudSyncEnabled() || !SupabaseService.isSignedIn) {
      return localConversations;
    }
    
    final cloudConversations = await getCloudConversations();
    
    // Combinar conversaciones locales y de la nube, evitando duplicados
    final Map<String, ChatConversation> conversationsMap = {};
    
    // Agregar conversaciones locales
    for (final conv in localConversations) {
      conversationsMap[conv.id] = conv;
    }
    
    // Agregar conversaciones de la nube (sobrescribir si existe localmente)
    for (final conv in cloudConversations) {
      conversationsMap[conv.id] = conv.copyWith(isCloudSynced: true);
    }
    
    final result = conversationsMap.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return result;
  }

  Future<void> saveConversation(ChatConversation conversation) async {
    try {
      // Siempre guardar localmente primero
      await saveLocalConversation(conversation);
      
      // Si la sincronización está habilitada, también guardar en la nube
      if (await isCloudSyncEnabled() && SupabaseService.isSignedIn) {
        try {
          await saveCloudConversation(conversation);
          // Marcar como sincronizado y guardar localmente de nuevo
          final syncedConversation = conversation.copyWith(isCloudSynced: true);
          await saveLocalConversation(syncedConversation);
        } catch (e) {
          debugPrint('Failed to sync conversation to cloud: $e');
          // La conversación se mantiene local
        }
      }
    } catch (e) {
      debugPrint('Error saving conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    // Eliminar localmente
    await deleteLocalConversation(conversationId);
    
    // Si la sincronización está habilitada, también eliminar de la nube
    if (await isCloudSyncEnabled() && SupabaseService.isSignedIn) {
      try {
        await deleteCloudConversation(conversationId);
      } catch (e) {
        debugPrint('Failed to delete conversation from cloud: $e');
      }
    }
  }

  Future<ChatConversation> createNewConversation(String firstMessage) async {
    // Generar título usando IA
    String title;
    try {
      title = await _openRouterService.generateConversationTitle(firstMessage);
    } catch (e) {
      // Si falla la generación con IA, usar el método por defecto
      debugPrint('Error generating AI title: $e');
      title = ChatConversation.generateTitle(firstMessage);
    }
    
    final conversation = ChatConversation(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // No guardar automáticamente al crear - se guardará cuando se agreguen mensajes
    return conversation;
  }

  Future<void> addMessageToConversation(String conversationId, ChatMessage message) async {
    final conversations = await getAllConversations();
    final conversationIndex = conversations.indexWhere((c) => c.id == conversationId);
    
    if (conversationIndex == -1) {
      throw Exception('Conversation not found: $conversationId');
    }
    
    final conversation = conversations[conversationIndex];
    final updatedConversation = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: DateTime.now(),
    );
    
    await saveConversation(updatedConversation);
  }

  // Sincronización
  Future<void> _syncLocalChatsToCloud() async {
    if (!SupabaseService.isSignedIn) return;
    
    try {
      final localConversations = await getLocalConversations();
      final cloudConversations = await getCloudConversations();
      
      // Crear un mapa de conversaciones de la nube por ID
      final cloudConversationsMap = {
        for (final conv in cloudConversations) conv.id: conv
      };
      
      // Sincronizar conversaciones locales que no estén en la nube o sean más recientes
      for (final localConv in localConversations) {
        final cloudConv = cloudConversationsMap[localConv.id];
        
        if (cloudConv == null || localConv.updatedAt.isAfter(cloudConv.updatedAt)) {
          await saveCloudConversation(localConv);
          // Actualizar el estado local para marcar como sincronizado
          await saveLocalConversation(localConv.copyWith(isCloudSynced: true));
        }
      }
      
      // También sincronizar conversaciones de la nube que no estén localmente
      for (final cloudConv in cloudConversations) {
        final hasLocal = localConversations.any((c) => c.id == cloudConv.id);
        if (!hasLocal) {
          await saveLocalConversation(cloudConv.copyWith(isCloudSynced: true));
        }
      }
      
    } catch (e) {
      debugPrint('Error syncing chats: $e');
    }
  }

  Future<void> forceSyncAllConversations() async {
    if (!await isCloudSyncEnabled() || !SupabaseService.isSignedIn) {
      return;
    }
    
    await _syncLocalChatsToCloud();
  }

  // Obtener una conversación específica por ID
  Future<ChatConversation?> getConversationById(String conversationId) async {
    final conversations = await getAllConversations();
    try {
      return conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Métodos para manejo de timestamps de sincronización
  Future<DateTime?> getLastSyncTime() async {
    await _initPrefs();
    final timestamp = _prefs!.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _initPrefs();
    await _prefs!.setString(_lastSyncKey, time.toIso8601String());
  }

  // Limpiar datos locales (útil para testing o reset)
  Future<void> clearLocalData() async {
    try {
      await _initPrefs();
      await _prefs!.remove(_localChatsKey);
      await _prefs!.remove(_lastSyncKey);
      _invalidateCache();
    } catch (e) {
      debugPrint('Error clearing local data: $e');
      rethrow;
    }
  }

  // Eliminar todo el historial (local y en la nube)
  Future<void> clearAllHistory() async {
    try {
      // Limpiar datos locales
      await clearLocalData();
      
      // Si está habilitada la sincronización en la nube, también limpiar ahí
      if (await isCloudSyncEnabled() && SupabaseService.isSignedIn) {
        await SupabaseService.clearAllConversations();
        await setLastSyncTime(DateTime.now());
      }
      
      // Invalidar cache
      _invalidateCache();
      
    } catch (e) {
      debugPrint('Error clearing all history: $e');
      rethrow;
    }
  }

  // Método para verificar si necesita sincronización
  Future<bool> needsSync() async {
    if (!await isCloudSyncEnabled() || !SupabaseService.isSignedIn) {
      return false;
    }
    
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    
    // Necesita sync si han pasado más de 5 minutos
    return DateTime.now().difference(lastSync) > const Duration(minutes: 5);
  }
}