import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input.dart';

import '../../services/openrouter_service.dart';
import '../../services/chat_state_manager.dart';
import '../../models/model_profile.dart';
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';
import '../../models/user_preferences.dart';
import '../../config/openrouter_config.dart';
import '../../services/supabase_service.dart';

import 'personalization_screen.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatConversation? existingConversation;
  
  const ChatScreen({super.key, this.existingConversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ChatStateManager _stateManager = ChatStateManager();
  late List<ChatMessage> _messages;
  late ModelProfile _selectedProfile;
  bool _isSending = false;
  late OpenRouterService _service;
  bool _showDisclaimer = true;
  int? _streamingIndex;
  Timer? _scrollTimer;
  bool _shouldScroll = false;
  bool _useReasoning = false;
  bool _showFirstTimeWarning = false;
  UserPreferences? _userPreferences;
  
  // Variables para el historial
  ChatConversation? _currentConversation;
  bool _hasFirstMessage = false;
  String? _conversationId; // ID único para esta sesión de chat

  @override
  void initState() {
    super.initState();
    _service = OpenRouterService();
    _selectedProfile = ModelProfile.defaultProfile;
    
    // Inicializar con conversación existente o nueva
    if (widget.existingConversation != null) {
      // Obtener la conversación más actualizada del state manager
      final updatedConversation = _stateManager.getConversationById(widget.existingConversation!.id) 
          ?? widget.existingConversation!;
      
      _currentConversation = updatedConversation;
      _conversationId = updatedConversation.id;
      _messages = List.from(updatedConversation.messages);
      _hasFirstMessage = _messages.any((m) => m.role == ChatRole.user);
      _showDisclaimer = _messages.isEmpty;
    } else {
      // Nueva conversación
      _messages = [];
      _conversationId = null; // Se asignará cuando se cree la conversación
      _addInitialAssistantMessage();
    }
    
    _checkFirstTimeUser();
    _loadUserPreferences();
  }

  Future<void> _checkFirstTimeUser() async {
    try {
      final isFirstTime = await SupabaseService.isFirstTimeUser();
      if (mounted) {
        setState(() {
          _showFirstTimeWarning = isFirstTime && _messages.length <= 1;
        });
      }
    } catch (e) {
      // Silently fail if we can't check - not critical
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final preferences = await SupabaseService.getUserPreferences();
      if (mounted) {
        setState(() {
          _userPreferences = preferences;
        });
      }
    } catch (e) {
      // Silently fail if we can't load preferences - not critical
    }
  }

  String _buildPersonalizedSystemPrompt() {
    String basePrompt = OpenRouterConfig.medicalSystemPrompt;
    
    if (_userPreferences == null) {
      return basePrompt;
    }
    
    List<String> personalizations = [];
    
    // Agregar información sobre alergias
    if (_userPreferences!.allergies.isNotEmpty) {
      personalizations.add(
        'IMPORTANTE: El usuario tiene las siguientes alergias: ${_userPreferences!.allergies.join(", ")}. '
        'SIEMPRE considera estas alergias al dar recomendaciones médicas, medicamentos o tratamientos.'
      );
    }
    
    // Agregar preferencia de medicina
    if (_userPreferences!.medicinePreference != MedicinePreference.both) {
      String preferenceText = _userPreferences!.medicinePreference == MedicinePreference.natural
          ? 'El usuario prefiere medicina natural y remedios alternativos'
          : 'El usuario prefiere medicina convencional y tratamientos farmacológicos';
      personalizations.add('$preferenceText. Ajusta tus recomendaciones según esta preferencia.');
    }
    
    // Agregar condiciones crónicas
    if (_userPreferences!.chronicConditions.isNotEmpty) {
      personalizations.add(
        'El usuario tiene las siguientes condiciones crónicas: ${_userPreferences!.chronicConditions.join(", ")}. '
        'Ten en cuenta estas condiciones al proporcionar consejos médicos.'
      );
    }
    
    // Agregar medicamentos actuales
    if (_userPreferences!.currentMedications.isNotEmpty) {
      personalizations.add(
        'El usuario toma actualmente los siguientes medicamentos: ${_userPreferences!.currentMedications.join(", ")}. '
        'Verifica posibles interacciones medicamentosas antes de recomendar nuevos tratamientos.'
      );
    }
    
    // Agregar información de edad y género si están disponibles
    if (_userPreferences!.ageRange != null) {
      personalizations.add('El usuario está en el rango de edad: ${_userPreferences!.ageRange!.displayName}.');
    }
    
    if (_userPreferences!.gender != null && _userPreferences!.gender != Gender.preferNotToSay) {
      personalizations.add('Género del usuario: ${_userPreferences!.gender!.displayName}.');
    }
    
    // Agregar notas adicionales
    if (_userPreferences!.additionalNotes != null && _userPreferences!.additionalNotes!.isNotEmpty) {
      personalizations.add('Notas adicionales del usuario: ${_userPreferences!.additionalNotes}');
    }
    
    // Construir el prompt personalizado
    if (personalizations.isNotEmpty) {
      return '$basePrompt\n\nINFORMACIÓN PERSONALIZADA DEL USUARIO:\n${personalizations.join("\n\n")}';
    }
    
    return basePrompt;
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _service.dispose();
    // Note: No need to dispose _stateManager as it's a singleton
    super.dispose();
  }

  String _assistantLabel() {
    final baseName = brandDisplayName(_selectedProfile.brand);
    return _useReasoning ? '$baseName • Razonamiento' : baseName;
  }

  void _addInitialAssistantMessage() {
    _messages.add(ChatMessage.assistant(
        'Hola, soy Docai. ¿En qué puedo ayudarte hoy?'));
  }

  Future<void> _createOrUpdateConversation(String firstUserMessage) async {
    if (_currentConversation == null) {
      // Crear nueva conversación usando el state manager
      _currentConversation = await _stateManager.createConversation(firstUserMessage);
      _conversationId = _currentConversation!.id;
      
      // Actualizar el título en el AppBar inmediatamente
      if (mounted) {
        setState(() {
          // Forzar reconstrucción del AppBar con el nuevo título
        });
      }
    }
    
    // Solo actualizar y guardar la conversación si tenemos mensajes
    if (_messages.isNotEmpty && _currentConversation != null) {
      // Actualizar la conversación con los mensajes actuales
      final updatedConversation = _currentConversation!.copyWith(
        messages: List.from(_messages), // Crear nueva lista para evitar referencias
        updatedAt: DateTime.now(),
      );
      
      await _stateManager.saveConversation(updatedConversation);
      _currentConversation = updatedConversation;
    }
  }

  Future<void> _startNewConversation() async {
    // Confirmar si el usuario quiere iniciar una nueva conversación
    if (_messages.length > 1) { // Solo preguntar si hay mensajes más allá del saludo inicial
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nueva conversación'),
          content: const Text('¿Estás seguro de que quieres iniciar una nueva conversación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Nueva conversación'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
    }
    
    // Limpiar el estado actual
    setState(() {
      _messages.clear();
      _currentConversation = null;
      _conversationId = null; // Reset conversation ID
      _hasFirstMessage = false;
      _showDisclaimer = true;
      _showFirstTimeWarning = false;
    });
    
    // Agregar mensaje inicial
    _addInitialAssistantMessage();
    await _scrollToBottom(force: true);
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar historial'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todo el historial de chats? '
          'Esta acción no se puede deshacer y eliminará todas las conversaciones '
          'tanto localmente como en la nube.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eliminando historial...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Eliminar todo el historial usando el state manager
      await _stateManager.clearAllHistory();
      
      // Limpiar el estado actual y empezar nueva conversación
      setState(() {
        _messages.clear();
        _currentConversation = null;
        _conversationId = null; // Reset conversation ID
        _hasFirstMessage = false;
        _showDisclaimer = true;
        _showFirstTimeWarning = false;
      });
      
      // Agregar mensaje inicial
      _addInitialAssistantMessage();
      await _scrollToBottom(force: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar historial: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(
    String text, {
    int? regenerateIndex,
    ModelProfile? overrideProfile,
    bool? overrideReasoning,
  }) async {
    final userMessage = ChatMessage.user(text);
    
    setState(() {
      if (regenerateIndex == null) {
        _messages.add(userMessage);
      } else {
        // Regeneration: remove only messages AFTER the given user message, keeping the user message itself
        if (regenerateIndex >= 0 && regenerateIndex < _messages.length - 1) {
          _messages.removeRange(regenerateIndex + 1, _messages.length);
        }
      }
      _isSending = true;
      _showDisclaimer = false;
    });

    // Crear o actualizar conversación si es el primer mensaje del usuario
    if (!_hasFirstMessage && regenerateIndex == null) {
      _hasFirstMessage = true;
      await _createOrUpdateConversation(text);
    }
    
    // Wait for the next frame to ensure the view has updated
    await Future.delayed(Duration.zero);
    await _scrollToBottom(force: true);

    try {
      final historyAll = _messages
          .where((m) => m.role != ChatRole.system)
          .toList();
      final history = historyAll.length > 24
          ? historyAll.sublist(historyAll.length - 24)
          : historyAll;
      
      // Add assistant placeholder
      setState(() {
        _messages.add(ChatMessage.assistant(''));
        _streamingIndex = _messages.length - 1;
      });
      
      // Wait for the next frame to ensure the view has updated
      await Future.delayed(Duration.zero);
      await _scrollToBottom(force: true);

      final stream = _service.streamChatCompletion(
        messages: history,
        profile: overrideProfile ?? _selectedProfile,
        systemPromptOverride: _buildPersonalizedSystemPrompt(),
        useReasoning: overrideReasoning ?? _useReasoning,
      );

      // Initial scroll to bottom before starting the stream
      _scrollToBottom(force: true);

      await for (final chunk in stream) {
        if (!mounted) break;
        setState(() {
          if (_streamingIndex != null && _streamingIndex! < _messages.length) {
            final curr = _messages[_streamingIndex!];
            _messages[_streamingIndex!] = ChatMessage(
              id: curr.id,
              role: curr.role,
              content: curr.content + chunk,
              createdAt: curr.createdAt,
            );
          }
        });

        // Only scroll if we're near the bottom
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (maxScroll - currentScroll < 300) {
          _scrollToBottom();
        }
      }

      // Guardar la conversación después de que se complete la respuesta del asistente
      if (_currentConversation != null) {
        await _createOrUpdateConversation(text);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ));
        // Show error in the assistant bubble if placeholder exists
        if (_streamingIndex != null && _streamingIndex! < _messages.length) {
          setState(() {
            _messages[_streamingIndex!] = ChatMessage(
              id: _messages[_streamingIndex!].id,
              role: ChatRole.assistant,
              content:
                  'Lo siento, ha ocurrido un error. Por favor, inténtalo de nuevo.',
              createdAt: DateTime.now(),
            );
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _streamingIndex = null;
        });
      }
    }
    _scrollToBottom();
  }

  Future<void> _scrollToBottom({bool force = false}) async {
    if (!_scrollController.hasClients) return;

    // Cancel any pending scroll
    _scrollTimer?.cancel();

    // Wait for the next frame to ensure the view has updated
    await Future.delayed(Duration.zero);

    if (force || !_scrollController.position.outOfRange) {
      // Immediate scroll without animation for force or when near bottom
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } else {
      // Smooth scroll when user has scrolled up
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<bool?> _showReasoningPickerSheet() async {
    bool tempReasoning = _useReasoning;
    
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configurar regeneración',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                brandColor(_selectedProfile.brand),
                                Color.lerp(brandColor(_selectedProfile.brand), Colors.black, 0.2)!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedProfile.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.psychology, size: 20, color: brandColor(_selectedProfile.brand)),
                      const SizedBox(width: 8),
                      const Text('Razonamiento avanzado'),
                      const Spacer(),
                      Switch(
                        value: tempReasoning,
                        onChanged: (value) => setState(() => tempReasoning = value),
                        activeColor: brandColor(_selectedProfile.brand),
                      ),
                    ],
                  ),
                  if (tempReasoning)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Docai proporcionará un análisis paso a paso más detallado.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(tempReasoning),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          child: Text('Regenerar'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _regenerateResponse(int assistantIndex) async {
    if (_isSending) return;
    if (assistantIndex <= 0) return;
    if (_messages[assistantIndex - 1].role != ChatRole.user) return;
    final userMessage = _messages[assistantIndex - 1];
    final newReasoning = await _showReasoningPickerSheet();
    if (newReasoning == null) return;
    
    if (newReasoning != _useReasoning) {
      setState(() {
        _useReasoning = newReasoning;
      });
    }
    
    await _sendMessage(
      userMessage.content,
      regenerateIndex: assistantIndex - 1,
      overrideProfile: _selectedProfile,
      overrideReasoning: newReasoning,
    );
  }

  String _getSyncStatusText(bool cloudSyncEnabled, bool isSyncing, DateTime? lastSyncTime, bool hasError) {
    if (hasError) {
      return 'Error en la sincronización. Toca refrescar para intentar de nuevo.';
    }
    
    if (!cloudSyncEnabled) {
      return 'Conversaciones guardadas solo en este dispositivo';
    }
    
    if (isSyncing) {
      return 'Sincronizando...';
    }
    
    if (lastSyncTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime);
      
      if (difference.inMinutes < 1) {
        return 'Sincronizado hace menos de un minuto';
      } else if (difference.inMinutes < 60) {
        return 'Sincronizado hace ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'Sincronizado hace ${difference.inHours}h';
      } else {
        return 'Sincronizado hace ${difference.inDays}d';
      }
    }
    
    return 'Sincronización automática habilitada';
  }

  Future<void> _toggleCloudSync(bool enabled) async {
    try {
      await _stateManager.toggleCloudSync(enabled);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled 
              ? 'Sincronización en la nube habilitada' 
              : 'Sincronización en la nube deshabilitada'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _forceSyncNow() async {
    if (!mounted) return;
    
    try {
      await _stateManager.forceSyncNow();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronización completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = brandColor(_selectedProfile.brand);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentConversation?.title ?? 'Docai'),
        actions: [
          // Botón para nueva conversación
          if (_hasFirstMessage)
            IconButton(
              tooltip: 'Nueva conversación',
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: _startNewConversation,
            ),
          // Botón para ver historial
          if (_hasFirstMessage)
            IconButton(
              tooltip: 'Ver historial',
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),

          IconButton(
            tooltip: 'Aviso',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Aviso médico'),
                  content: Text(OpenRouterConfig.disclaimerText),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Entendido'),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              itemCount: _messages.length + 
                (_showDisclaimer ? 1 : 0) + 
                (_showFirstTimeWarning ? 1 : 0) + 
                (_hasFirstMessage ? 1 : 0), // Card de sincronización
              itemBuilder: (context, index) {
                int cardOffset = 0;
                
                
                // Card de disclaimer
                if (_showDisclaimer) {
                  if (index == cardOffset) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withOpacity(0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.local_hospital_outlined, color: accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              OpenRouterConfig.disclaimerText,
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _showDisclaimer = false),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, size: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  cardOffset++;
                }
                
                // Card de primera vez
                if (_showFirstTimeWarning) {
                  if (index == cardOffset) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tune, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Personaliza tu experiencia',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () async {
                                  await SupabaseService.markAsNotFirstTime();
                                  setState(() => _showFirstTimeWarning = false);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.close, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Para ofrecerte recomendaciones más precisas, configura tus preferencias médicas, alergias y condiciones.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await SupabaseService.markAsNotFirstTime();
                                  setState(() => _showFirstTimeWarning = false);
                                },
                                child: Text(
                                  'Ahora no',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () async {
                                  await SupabaseService.markAsNotFirstTime();
                                  setState(() => _showFirstTimeWarning = false);
                                  if (mounted) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PersonalizationScreen(),
                                      ),
                                    );
                                    await _loadUserPreferences();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: const Text(
                                  'Personalizar',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  cardOffset++;
                }
                
                // Mensajes del chat
                final messageIndex = index - cardOffset;
                if (messageIndex >= 0 && messageIndex < _messages.length) {
                  final m = _messages[messageIndex];
                  final isAssistant = m.role == ChatRole.assistant;
                  final isWelcomeMessage = messageIndex == 0 && isAssistant && _messages.length == 1;

                  return MessageBubble(
                    message: m.content,
                    isAssistant: isAssistant,
                    assistantLabel: _assistantLabel(),
                    accentColor: brandColor(_selectedProfile.brand),
                    isStreaming:
                        isAssistant &&
                        _streamingIndex != null &&
                        messageIndex == _streamingIndex,
                    showRegenerateButton: isAssistant && !isWelcomeMessage,
                    onRegenerate: isAssistant && !isWelcomeMessage
                        ? () => _regenerateResponse(messageIndex)
                        : null,
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
          ChatInput(
            onSend: (text) => _sendMessage(text),
            isSending: _isSending,
            selectedProfile: _selectedProfile,
            allProfiles: ModelProfile.defaults(),
            useReasoning: _useReasoning,
            onProfileChanged: (p) {
              setState(() {
                _selectedProfile = p;
              });
            },
            onReasoningChanged: (enabled) {
              setState(() {
                _useReasoning = enabled;
              });
            },
            onRequestPro: () {},
          ),
        ],
      ),
    );
  }
}