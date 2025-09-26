import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/chat_conversation.dart';
import 'chat_history_service.dart';
import 'supabase_service.dart';

/// Gestor centralizado del estado de conversaciones de chat
/// Proporciona una fuente única de verdad para todas las pantallas
class ChatStateManager extends ChangeNotifier {
  static final ChatStateManager _instance = ChatStateManager._internal();
  factory ChatStateManager() => _instance;
  ChatStateManager._internal();

  final ChatHistoryService _historyService = ChatHistoryService();
  
  // Estado principal
  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _cloudSyncEnabled = false;
  String? _error;
  DateTime? _lastSyncTime;
  
  // Estado de navegación
  ChatConversation? _currentConversation;
  bool _shouldClearCurrentConversation = false;
  
  // Cache y estado de sincronización
  Timer? _syncTimer;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _retryDelay = Duration(seconds: 30);
  
  // Getters públicos
  List<ChatConversation> get conversations => List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get cloudSyncEnabled => _cloudSyncEnabled;
  String? get error => _error;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get hasError => _error != null;
  
  // Getters para navegación
  ChatConversation? get currentConversation => _currentConversation;
  bool get shouldClearCurrentConversation => _shouldClearCurrentConversation;
  
  // Stream para escuchar cambios en tiempo real
  final StreamController<List<ChatConversation>> _conversationsStreamController = 
      StreamController<List<ChatConversation>>.broadcast();
  Stream<List<ChatConversation>> get conversationsStream => 
      _conversationsStreamController.stream;

  /// Inicializar el gestor de estado
  Future<void> initialize() async {
    await _loadInitialData();
    await _loadSyncSettings();
    _startPeriodicSync();
  }

  /// Cargar datos iniciales (siempre desde local primero)
  Future<void> _loadInitialData() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Cargar conversaciones locales inmediatamente
      final localConversations = await _historyService.getLocalConversations();
      _updateConversations(localConversations);
      
      // Si la sincronización está habilitada, hacer sync en background
      if (_cloudSyncEnabled) {
        _syncInBackground();
      }
    } catch (e) {
      _setError('Error cargando conversaciones: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar las conversaciones y notificar a los listeners
  void _updateConversations(List<ChatConversation> conversations) {
    _conversations = conversations..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _conversationsStreamController.add(_conversations);
    notifyListeners();
  }

  /// Refrescar datos (forzar recarga)
  Future<void> refresh() async {
    _clearError();
    await _loadInitialData();
  }

  /// Cargar configuración de sincronización
  Future<void> _loadSyncSettings() async {
    try {
      _cloudSyncEnabled = await _historyService.isCloudSyncEnabled();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sync settings: $e');
    }
  }

  /// Alternar sincronización en la nube
  Future<void> toggleCloudSync(bool enabled) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _historyService.setCloudSyncEnabled(enabled);
      _cloudSyncEnabled = enabled;
      
      if (enabled) {
        // Forzar sincronización inicial
        await _performSync();
      } else {
        // Detener sincronización automática
        _stopPeriodicSync();
      }
      
      await refresh(); // Recargar datos después del cambio
      
    } catch (e) {
      _setError('Error configurando sincronización: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Crear nueva conversación
  Future<ChatConversation> createConversation(String firstMessage) async {
    try {
      _clearError();
      final conversation = await _historyService.createNewConversation(firstMessage);
      
      // Agregar a la lista local inmediatamente
      _conversations.insert(0, conversation);
      _updateConversations(_conversations);
      
      return conversation;
    } catch (e) {
      _setError('Error creando conversación: $e');
      rethrow;
    }
  }

  /// Guardar conversación (actualizar existente o crear nueva)
  Future<void> saveConversation(ChatConversation conversation) async {
    try {
      _clearError();
      
      // Guardar usando el servicio
      await _historyService.saveConversation(conversation);
      
      // Actualizar en la lista local
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index != -1) {
        _conversations[index] = conversation;
      } else {
        _conversations.insert(0, conversation);
      }
      
      _updateConversations(_conversations);
      
    } catch (e) {
      _setError('Error guardando conversación: $e');
      rethrow;
    }
  }

  /// Eliminar conversación
  Future<void> deleteConversation(String conversationId) async {
    try {
      _clearError();
      
      // Eliminar usando el servicio
      await _historyService.deleteConversation(conversationId);
      
      // Remover de la lista local
      _conversations.removeWhere((c) => c.id == conversationId);
      _updateConversations(_conversations);
      
    } catch (e) {
      _setError('Error eliminando conversación: $e');
      rethrow;
    }
  }

  /// Eliminar todo el historial
  Future<void> clearAllHistory() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _historyService.clearAllHistory();
      _conversations.clear();
      _updateConversations(_conversations);
      
    } catch (e) {
      _setError('Error eliminando historial: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener una conversación específica por ID
  ChatConversation? getConversationById(String conversationId) {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }
  
  /// Establecer conversación actual para navegación
  void setCurrentConversation(ChatConversation conversation) {
    _currentConversation = conversation;
    _shouldClearCurrentConversation = false;
    notifyListeners();
  }
  
  /// Limpiar conversación actual para empezar una nueva
  void clearCurrentConversation() {
    _currentConversation = null;
    _shouldClearCurrentConversation = true;
    notifyListeners();
  }
  
  /// Limpiar bandera de limpiar conversación
  void clearShouldClearFlag() {
    _shouldClearCurrentConversation = false;
  }

  /// Sincronización en background (silenciosa)
  Future<void> _syncInBackground() async {
    if (!_cloudSyncEnabled || _isSyncing) return;
    
    try {
      _setSyncing(true);
      await _performSync();
      _retryCount = 0; // Reset retry count on success
      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Background sync failed: $e');
      _scheduleRetry();
    } finally {
      _setSyncing(false);
    }
  }

  /// Realizar sincronización
  Future<void> _performSync() async {
    if (!_cloudSyncEnabled || !SupabaseService.isSignedIn) return;
    
    // Forzar sincronización usando el servicio
    await _historyService.forceSyncAllConversations();
    
    // Recargar conversaciones después de la sincronización
    final allConversations = await _historyService.getAllConversations();
    _updateConversations(allConversations);
  }

  /// Programar reintento de sincronización
  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) {
      debugPrint('Max sync retries reached');
      return;
    }
    
    _retryCount++;
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      _syncInBackground();
    });
  }

  /// Iniciar sincronización periódica
  void _startPeriodicSync() {
    if (!_cloudSyncEnabled) return;
    
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      _syncInBackground();
    });
  }

  /// Detener sincronización periódica
  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _retryTimer?.cancel();
  }

  /// Forzar sincronización manual (con feedback al usuario)
  Future<void> forceSyncNow() async {
    if (!_cloudSyncEnabled) {
      throw Exception('La sincronización en la nube está deshabilitada');
    }
    
    if (!SupabaseService.isSignedIn) {
      throw Exception('No hay sesión iniciada');
    }
    
    try {
      _setSyncing(true);
      _clearError();
      
      await _performSync();
      _lastSyncTime = DateTime.now();
      _retryCount = 0;
      
    } catch (e) {
      _setError('Error en sincronización: $e');
      rethrow;
    } finally {
      _setSyncing(false);
    }
  }

  // Métodos de estado internos
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setSyncing(bool syncing) {
    if (_isSyncing != syncing) {
      _isSyncing = syncing;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    _setError(null);
  }

  /// Limpiar recursos
  @override
  void dispose() {
    _stopPeriodicSync();
    _conversationsStreamController.close();
    super.dispose();
  }

  /// Manejar cambios en el estado de la aplicación
  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _cloudSyncEnabled) {
      // Sincronizar cuando la app vuelve al foreground
      _syncInBackground();
    }
  }

  /// Notificar cambio en una conversación específica
  void notifyConversationChanged(ChatConversation conversation) {
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _conversations[index] = conversation;
      _updateConversations(_conversations);
    }
  }
}