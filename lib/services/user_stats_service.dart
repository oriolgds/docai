import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import 'chat_history_service.dart';
import 'supabase_service.dart';

class UserStatsService {
  static final UserStatsService _instance = UserStatsService._internal();
  factory UserStatsService() => _instance;
  UserStatsService._internal();

  final ChatHistoryService _chatHistoryService = ChatHistoryService();
  
  // Cache para optimizar rendimiento
  UserStats? _cachedStats;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  bool _isCacheValid() {
    return _cachedStats != null && 
           _cacheTimestamp != null && 
           DateTime.now().difference(_cacheTimestamp!) < _cacheValidDuration;
  }

  void _invalidateCache() {
    _cachedStats = null;
    _cacheTimestamp = null;
  }

  /// Obtiene las estadísticas completas del usuario
  Future<UserStats> getUserStats({bool forceRefresh = false}) async {
    // Usar cache si es válido y no se fuerza refresh
    if (!forceRefresh && _isCacheValid()) {
      return _cachedStats!;
    }

    try {
      final conversations = await _chatHistoryService.getAllConversations();
      final stats = await _calculateStats(conversations);
      
      // Actualizar cache
      _cachedStats = stats;
      _cacheTimestamp = DateTime.now();
      
      return stats;
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      // Si hay error, devolver stats por defecto
      return UserStats.empty();
    }
  }

  /// Calcula las estadísticas basadas en las conversaciones
  Future<UserStats> _calculateStats(List<ChatConversation> conversations) async {
    if (conversations.isEmpty) {
      return UserStats.empty();
    }

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    // Contar conversaciones totales
    final totalConversations = conversations.length;
    
    // Contar mensajes totales del usuario (no incluir respuestas del bot)
    int totalUserMessages = 0;
    int totalBotMessages = 0;
    int totalCharacters = 0;
    DateTime? lastActivityDate;
    
    // Estadísticas semanales y mensuales
    int conversationsThisWeek = 0;
    int conversationsThisMonth = 0;
    int messagesThisWeek = 0;
    int messagesThisMonth = 0;
    
    // Para calcular satisfacción (simulada basada en longitud de conversaciones)
    double satisfactionScore = 0.0;
    int satisfactionSamples = 0;
    
    // Lista de días de actividad para el gráfico semanal
    final weeklyActivity = <DateTime, int>{};
    
    for (final conversation in conversations) {
      // Verificar si está en el rango de tiempo
      final isThisWeek = conversation.updatedAt.isAfter(oneWeekAgo);
      final isThisMonth = conversation.updatedAt.isAfter(oneMonthAgo);
      
      if (isThisWeek) conversationsThisWeek++;
      if (isThisMonth) conversationsThisMonth++;
      
      // Contar mensajes por tipo y encontrar el último mensaje
      int userMessagesInConv = 0;
      int botMessagesInConv = 0;
      
      for (final message in conversation.messages) {
        totalCharacters += message.content.length;
        
        // Actualizar última actividad con el mensaje más reciente
        if (lastActivityDate == null || message.createdAt.isAfter(lastActivityDate)) {
          lastActivityDate = message.createdAt;
        }
        
        if (message.role == ChatRole.user) {
          totalUserMessages++;
          userMessagesInConv++;
          if (isThisWeek) messagesThisWeek++;
          if (isThisMonth) messagesThisMonth++;
          
          // Añadir a actividad semanal
          final dayKey = DateTime(message.createdAt.year, message.createdAt.month, message.createdAt.day);
          if (dayKey.isAfter(oneWeekAgo)) {
            weeklyActivity[dayKey] = (weeklyActivity[dayKey] ?? 0) + 1;
          }
        } else {
          totalBotMessages++;
          botMessagesInConv++;
        }
      }
      
      // Calcular "satisfacción" basada en la interacción
      // Más mensajes de intercambio = mayor satisfacción
      if (userMessagesInConv > 0 && botMessagesInConv > 0) {
        final interactionRatio = (botMessagesInConv / userMessagesInConv).clamp(0.5, 2.0);
        final lengthBonus = (userMessagesInConv / 10).clamp(0.0, 1.0);
        final score = (interactionRatio * 0.4 + lengthBonus * 0.6) * 100;
        satisfactionScore += score;
        satisfactionSamples++;
      }
    }
    
    // Calcular promedio de satisfacción
    final averageSatisfaction = satisfactionSamples > 0 
        ? (satisfactionScore / satisfactionSamples).clamp(0.0, 100.0)
        : 85.0; // Valor por defecto
    
    // Calcular minutos de chat estimados (basado en caracteres)
    final estimatedMinutes = (totalCharacters / 200).round(); // ~200 caracteres por minuto
    
    // Generar actividad semanal completa (7 días)
    final weeklyActivityList = <int>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      weeklyActivityList.add(weeklyActivity[dayKey] ?? 0);
    }
    
    return UserStats(
      totalConversations: totalConversations,
      totalUserMessages: totalUserMessages,
      totalBotMessages: totalBotMessages,
      totalCharacters: totalCharacters,
      estimatedChatMinutes: estimatedMinutes,
      lastActivityDate: lastActivityDate,
      conversationsThisWeek: conversationsThisWeek,
      conversationsThisMonth: conversationsThisMonth,
      messagesThisWeek: messagesThisWeek,
      messagesThisMonth: messagesThisMonth,
      averageSatisfactionScore: averageSatisfaction,
      weeklyActivity: weeklyActivityList,
      accountCreatedDate: _getAccountCreatedDate(),
      isCloudSyncEnabled: await _chatHistoryService.isCloudSyncEnabled(),
    );
  }
  
  DateTime? _getAccountCreatedDate() {
    final user = SupabaseService.currentUser;
    return user?.createdAt != null ? DateTime.parse(user!.createdAt!) : null;
  }
  
  /// Métodos específicos para obtener datos individuales (más rápido)
  Future<int> getTotalConversationsCount() async {
    try {
      final conversations = await _chatHistoryService.getAllConversations();
      return conversations.length;
    } catch (e) {
      debugPrint('Error getting conversations count: $e');
      return 0;
    }
  }
  
  /// Busca el último mensaje de todas las conversaciones
  /// Siempre obtiene datos frescos del ChatHistoryService
  Future<DateTime?> getLastActivityDate() async {
    try {
      // Forzar obtención de datos frescos para la última actividad
      final conversations = await _chatHistoryService.getAllConversations();
      if (conversations.isEmpty) return null;
      
      DateTime? lastMessageDate;
      
      // Buscar el último mensaje de todas las conversaciones
      for (final conversation in conversations) {
        if (conversation.messages.isEmpty) continue;
        
        // Ordenar mensajes por fecha para asegurar que obtenemos el último
        final sortedMessages = List<ChatMessage>.from(conversation.messages)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        final lastMessageInConv = sortedMessages.last;
        
        if (lastMessageDate == null || lastMessageInConv.createdAt.isAfter(lastMessageDate)) {
          lastMessageDate = lastMessageInConv.createdAt;
        }
      }
      
      return lastMessageDate;
    } catch (e) {
      debugPrint('Error getting last activity: $e');
      return null;
    }
  }
  
  Future<String> getFormattedLastActivity() async {
    final lastActivity = await getLastActivityDate();
    if (lastActivity == null) return 'Nunca';
    
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}sem';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}mes';
    }
  }
  
  /// Limpiar cache cuando se actualicen los datos
  /// Llamar este método después de agregar nuevos mensajes
  void invalidateCache() {
    _invalidateCache();
  }
  
  /// Forzar actualización de estadísticas y cache
  Future<UserStats> refreshStats() async {
    return await getUserStats(forceRefresh: true);
  }
}

/// Clase que representa las estadísticas del usuario
class UserStats {
  final int totalConversations;
  final int totalUserMessages;
  final int totalBotMessages;
  final int totalCharacters;
  final int estimatedChatMinutes;
  final DateTime? lastActivityDate;
  final int conversationsThisWeek;
  final int conversationsThisMonth;
  final int messagesThisWeek;
  final int messagesThisMonth;
  final double averageSatisfactionScore;
  final List<int> weeklyActivity; // 7 días de actividad
  final DateTime? accountCreatedDate;
  final bool isCloudSyncEnabled;
  
  const UserStats({
    required this.totalConversations,
    required this.totalUserMessages,
    required this.totalBotMessages,
    required this.totalCharacters,
    required this.estimatedChatMinutes,
    this.lastActivityDate,
    required this.conversationsThisWeek,
    required this.conversationsThisMonth,
    required this.messagesThisWeek,
    required this.messagesThisMonth,
    required this.averageSatisfactionScore,
    required this.weeklyActivity,
    this.accountCreatedDate,
    required this.isCloudSyncEnabled,
  });
  
  factory UserStats.empty() {
    return const UserStats(
      totalConversations: 0,
      totalUserMessages: 0,
      totalBotMessages: 0,
      totalCharacters: 0,
      estimatedChatMinutes: 0,
      lastActivityDate: null,
      conversationsThisWeek: 0,
      conversationsThisMonth: 0,
      messagesThisWeek: 0,
      messagesThisMonth: 0,
      averageSatisfactionScore: 0.0,
      weeklyActivity: [0, 0, 0, 0, 0, 0, 0],
      accountCreatedDate: null,
      isCloudSyncEnabled: false,
    );
  }
  
  /// Obtener el último uso formateado
  String get formattedLastActivity {
    if (lastActivityDate == null) return 'Nunca';
    
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate!);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}sem';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}mes';
    }
  }
  
  /// Obtener satisfacción formateada
  String get formattedSatisfaction {
    return '${averageSatisfactionScore.round()}%';
  }
  
  /// Obtener minutos formateados
  String get formattedChatTime {
    if (estimatedChatMinutes < 60) {
      return '${estimatedChatMinutes}min';
    } else if (estimatedChatMinutes < 1440) { // 24 horas
      final hours = (estimatedChatMinutes / 60).floor();
      final minutes = estimatedChatMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    } else {
      final days = (estimatedChatMinutes / 1440).floor();
      return '${days}d';
    }
  }
  
  /// Verificar si el usuario está activo esta semana
  bool get isActiveThisWeek => conversationsThisWeek > 0;
  
  /// Obtener porcentaje de actividad semanal
  double get weeklyActivityPercentage {
    final totalWeeklyMessages = weeklyActivity.fold(0, (sum, day) => sum + day);
    if (totalWeeklyMessages == 0) return 0.0;
    
    // Calcular basado en un máximo arbitrario de 20 mensajes por día
    const maxMessagesPerDay = 20;
    const maxWeeklyMessages = maxMessagesPerDay * 7;
    
    return (totalWeeklyMessages / maxWeeklyMessages * 100).clamp(0.0, 100.0);
  }
}