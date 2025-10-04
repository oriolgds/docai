import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../services/openrouter_service.dart';
import '../../services/chat_state_manager.dart';
import '../../services/model_service.dart';
import '../../models/model_profile.dart';
import '../../exceptions/model_exceptions.dart';
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';
import '../../models/user_preferences.dart';
import '../../config/openrouter_config.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../services/medical_data_bridge_service.dart';

import '../medical_preferences_screen.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatConversation? existingConversation;
  final VoidCallback? onNavigateToHistory;
  
  const ChatScreen({
    super.key, 
    this.existingConversation,
    this.onNavigateToHistory,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ChatStateManager _stateManager = ChatStateManager();
  late List<ChatMessage> _messages;
  ModelProfile _selectedProfile = ModelProfile.defaultProfile;
  bool _isSending = false;
  late OpenRouterService _service;
  bool _showDisclaimer = true;
  int? _streamingIndex;
  Timer? _scrollTimer;
  bool _shouldScroll = false;
  bool _useReasoning = false;
  bool _showFirstTimeWarning = false;
  UserPreferences? _userPreferences;
  bool _isInitialized = false; // Flag to track initialization
  StreamSubscription<String>? _currentStreamSubscription; // Track current stream
  
  // Variables para el historial
  ChatConversation? _currentConversation;
  bool _hasFirstMessage = false;
  String? _conversationId; // ID único para esta sesión de chat

  // Variables para el scroll mejorado
  bool _showScrollToBottomButton = false;
  bool _isUserScrolling = false;
  Timer? _scrollVisibilityTimer;
  double _lastScrollOffset = 0.0;
  static const double _scrollThreshold = 150.0; // Pixeles desde abajo para mostrar botón

  @override
  void initState() {
    super.initState();
    _service = OpenRouterService();
    _initializeDefaultModel();
    
    // Configurar listener del scroll controller
    _scrollController.addListener(_onScrollChanged);
    
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
      // Nueva conversación - no agregar mensaje inicial aquí
      _messages = [];
      _conversationId = null; // Se asignará cuando se cree la conversación
      // El mensaje inicial se agregará en didChangeDependencies cuando las localizaciones estén disponibles
    }
    
    _checkFirstTimeUser();
    
    // Cargar preferencias antes que nada para tenerlas disponibles
    _loadUserPreferences();
    
    // Escuchar cambios en el state manager para manejar conversaciones externas
    _stateManager.addListener(_onStateManagerChanged);
  }
  
  Future<void> _initializeDefaultModel() async {
    try {
      final defaultModel = await ModelService.getDefaultModel();
      if (defaultModel != null && mounted) {
        setState(() {
          _selectedProfile = defaultModel;
        });
      }
    } catch (e) {
      // Ya tiene el valor por defecto
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Inicializar mensaje inicial cuando las localizaciones estén disponibles
    if (!_isInitialized && widget.existingConversation == null && _messages.isEmpty) {
      _addInitialAssistantMessage();
      _isInitialized = true;
      // Recargar preferencias para asegurar que estén disponibles
      _loadUserPreferences();
    }
  }
  
  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    
    final currentOffset = _scrollController.offset;
    final maxOffset = _scrollController.position.maxScrollExtent;
    final distanceFromBottom = maxOffset - currentOffset;
    
    // Determinar si mostrar el botón de scroll al final
    final shouldShowButton = distanceFromBottom > _scrollThreshold;
    
    if (shouldShowButton != _showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = shouldShowButton;
      });
    }
    
    // Detectar si el usuario está haciendo scroll manualmente
    final scrollingUp = currentOffset < _lastScrollOffset;
    if (scrollingUp && distanceFromBottom > 50) {
      _isUserScrolling = true;
      _scrollVisibilityTimer?.cancel();
      _scrollVisibilityTimer = Timer(const Duration(seconds: 2), () {
        _isUserScrolling = false;
      });
    }
    
    _lastScrollOffset = currentOffset;
  }
  
  void _onStateManagerChanged() {
    // Verificar si hay una conversación pendiente o si se debe limpiar
    final currentConversation = _stateManager.currentConversation;
    final shouldClearConversation = _stateManager.shouldClearCurrentConversation;
    
    if (shouldClearConversation) {
      // Limpiar la conversación actual
      _startNewConversation();
      _stateManager.clearShouldClearFlag(); // Limpiar la bandera
    } else if (currentConversation != null && 
               currentConversation.id != _conversationId) {
      // Cargar la nueva conversación
      setState(() {
        _currentConversation = currentConversation;
        _conversationId = currentConversation.id;
        _messages = List.from(currentConversation.messages);
        _hasFirstMessage = _messages.any((m) => m.role == ChatRole.user);
        _showDisclaimer = _messages.isEmpty;
        if (_messages.isEmpty) {
          _addInitialAssistantMessage();
        }
      });
      
      // Scroll al final después de cargar los mensajes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(force: true);
      });
    }
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
      // First try to sync medical data to ensure comprehensive preferences are available
      await MedicalDataBridgeService.syncMedicalDataToChat();
      
      // Then load the user preferences for chat
      final preferences = await SupabaseService.getUserPreferences();
      if (mounted) {
        setState(() {
          _userPreferences = preferences;
        });
        // Rebuild to apply new preferences to system prompt
        if (_messages.isNotEmpty) {
          setState(() {});
        }
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
    _scrollVisibilityTimer?.cancel();
    _currentStreamSubscription?.cancel();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    _service.dispose();
    _stateManager.removeListener(_onStateManagerChanged);
    super.dispose();
  }

  String _assistantLabel() {
    final baseName = brandDisplayName(_selectedProfile.brand);
    return _useReasoning ? '$baseName • Razonamiento' : baseName;
  }

  void _addInitialAssistantMessage() {
    // Solo agregar si tenemos acceso a las localizaciones y no hay mensajes
    if (_messages.isEmpty && mounted) {
      try {
        final l10n = AppLocalizations.of(context)!;
        _messages.add(ChatMessage.assistant(l10n.helloImDocai));
      } catch (e) {
        // Fallback si las localizaciones no están disponibles
        _messages.add(ChatMessage.assistant('Hola, soy Docai. ¿Cómo puedo ayudarte hoy?'));
      }
    }
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
    if (!mounted) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    // Confirmar si el usuario quiere iniciar una nueva conversación
    if (_messages.length > 1) { // Solo preguntar si hay mensajes más allá del saludo inicial
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.newConversation),
          content: Text(l10n.newConversationConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.newConversation),
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
    if (!mounted) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteHistory),
        content: Text(l10n.deleteHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deletingHistory),
            duration: const Duration(seconds: 2),
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
          SnackBar(
            content: Text(l10n.historyDeletedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingHistory(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // New method to handle cancellation
  Future<void> _cancelGeneration() async {
    if (!_isSending) return;
    
    // Cancel the current stream
    await _currentStreamSubscription?.cancel();
    _currentStreamSubscription = null;
    
    // Cancel stream in service
    await _service.cancelCurrentStream();
    
    // Update UI state
    if (mounted) {
      setState(() {
        _isSending = false;
        _streamingIndex = null;
      });
      
      // Remove the incomplete assistant message if it exists
      if (_messages.isNotEmpty && 
          _messages.last.role == ChatRole.assistant && 
          _messages.last.content.trim().isEmpty) {
        setState(() {
          _messages.removeLast();
        });
      }
      
      // Show cancellation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generación cancelada'),
          duration: Duration(seconds: 2),
        ),
      );
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

      // Cancel any existing subscription
      await _currentStreamSubscription?.cancel();
      
      // Listen to the stream
      _currentStreamSubscription = stream.listen(
        (chunk) {
          if (!mounted) return;
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

          // Mejorar el auto-scroll durante streaming
          // Solo hacer scroll automático si el usuario no está scrolleando manualmente
          // y si está cerca del final
          if (_scrollController.hasClients && !_isUserScrolling) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            final currentScroll = _scrollController.offset;
            final distanceFromBottom = maxScroll - currentScroll;
            
            // Auto scroll si está cerca del final (menos de 200px)
            if (distanceFromBottom < 200) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
            }
          }
        },
        onDone: () async {
          // Stream completed successfully
          _currentStreamSubscription = null;
          
          if (mounted) {
            setState(() {
              _isSending = false;
              _streamingIndex = null;
            });
          }
          
          // Save the conversation after completion
          if (_currentConversation != null) {
            await _createOrUpdateConversation(text);
          }
        },
        onError: (e) {
          _currentStreamSubscription = null;
          
          if (mounted) {
            String errorMessage;
            if (e is ModelUnavailableException) {
              errorMessage = e.toString();
            } else {
              errorMessage = 'Error: ${e.toString()}';
            }
            
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(errorMessage),
              behavior: SnackBarBehavior.floating,
            ));
            
            // Show error in the assistant bubble if placeholder exists
            if (_streamingIndex != null && _streamingIndex! < _messages.length) {
              setState(() {
                _messages[_streamingIndex!] = ChatMessage(
                  id: _messages[_streamingIndex!].id,
                  role: ChatRole.assistant,
                  content: e is ModelUnavailableException 
                    ? 'El modelo seleccionado no está disponible. Por favor, selecciona otro modelo e inténtalo de nuevo.'
                    : 'Lo siento, ha ocurrido un error. Por favor, inténtalo de nuevo.',
                  createdAt: DateTime.now(),
                );
              });
            }
            
            setState(() {
              _isSending = false;
              _streamingIndex = null;
            });
          }
        },
      );

    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e is ModelUnavailableException) {
          errorMessage = e.toString();
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
        ));
        // Show error in the assistant bubble if placeholder exists
        if (_streamingIndex != null && _streamingIndex! < _messages.length) {
          setState(() {
            _messages[_streamingIndex!] = ChatMessage(
              id: _messages[_streamingIndex!].id,
              role: ChatRole.assistant,
              content: e is ModelUnavailableException 
                ? 'El modelo seleccionado no está disponible. Por favor, selecciona otro modelo e inténtalo de nuevo.'
                : 'Lo siento, ha ocurrido un error. Por favor, inténtalo de nuevo.',
              createdAt: DateTime.now(),
            );
          });
        }
        
        setState(() {
          _isSending = false;
          _streamingIndex = null;
        });
      }
    }
    
    // Final scroll to bottom after message is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
  
  // Método para hacer scroll al final con el botón
  void _scrollToBottomButtonPressed() {
    if (!_scrollController.hasClients) return;
    
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<bool?> _showReasoningPickerSheet() async {
    if (!mounted) return null;
    
    final l10n = AppLocalizations.of(context)!;
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
                  Text(
                    l10n.configureRegeneration,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                                Color.lerp(brandColor(_selectedProfile.brand), AppTheme.darkGreen, 0.2)!,
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
                      Text(l10n.advancedReasoning),
                      const Spacer(),
                      Switch(
                        value: tempReasoning,
                        onChanged: (value) => setState(() => tempReasoning = value),
                      ),
                    ],
                  ),
                  if (tempReasoning)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        l10n.advancedReasoningDescription,
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
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(tempReasoning),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          child: Text(l10n.regenerate),
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
    if (!mounted) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    if (hasError) {
      return l10n.syncError;
    }
    
    if (!cloudSyncEnabled) {
      return l10n.conversationsLocalOnly;
    }
    
    if (isSyncing) {
      return l10n.syncing;
    }
    
    if (lastSyncTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime);
      
      if (difference.inMinutes < 1) {
        return l10n.syncedLessThanMinute;
      } else if (difference.inMinutes < 60) {
        return l10n.syncedMinutesAgo(difference.inMinutes);
      } else if (difference.inHours < 24) {
        return l10n.syncedHoursAgo(difference.inHours);
      } else {
        return l10n.syncedDaysAgo(difference.inDays);
      }
    }
    
    return l10n.autoSyncEnabled;
  }

  Future<void> _toggleCloudSync(bool enabled) async {
    if (!mounted) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await _stateManager.toggleCloudSync(enabled);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled 
              ? l10n.cloudSyncEnabled 
              : l10n.cloudSyncDisabled),
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
    
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await _stateManager.forceSyncNow();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncCompleted),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToHistory() {
    // Si tenemos callback de navegación, cambiar a la tab de historial
    // Si no, usar navegación tradicional (fallback)
    if (widget.onNavigateToHistory != null) {
      widget.onNavigateToHistory!();
    } else {
      // Fallback: navegación tradicional
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HistoryScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = _selectedProfile.primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentConversation?.title ?? l10n.appTitle),
        actions: [
          // Botón para nueva conversación
          if (_hasFirstMessage)
            IconButton(
              tooltip: l10n.newConversation,
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: _startNewConversation,
            ),
          // Botón para ver historial
          if (_hasFirstMessage)
            IconButton(
              tooltip: l10n.viewHistory,
              icon: const Icon(Icons.history),
              onPressed: _navigateToHistory,
            ),

          IconButton(
            tooltip: l10n.medicalNotice,
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l10n.medicalNotice),
                  content: Text(OpenRouterConfig.disclaimerText),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.understood),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.25)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.local_hospital_outlined, color: theme.colorScheme.primary, size: 20),
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
                              colors: [_selectedProfile.primaryColor.withOpacity(0.1), _selectedProfile.secondaryColor.withOpacity(0.2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.tune, color: _selectedProfile.primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.personalizeYourExperience,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedProfile.primaryColor,
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
                                l10n.personalizeExperienceMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface,
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
                                      l10n.notNow,
                                      style: TextStyle(
                                        color: _selectedProfile.primaryColor,
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
                                            builder: (context) => const MedicalPreferencesScreen(),
                                          ),
                                        );
                                        await _loadUserPreferences();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedProfile.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                    child: Text(
                                      l10n.personalize,
                                      style: const TextStyle(fontSize: 12),
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
                        accentColor: _selectedProfile.primaryColor,
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
              FutureBuilder<List<ModelProfile>>(
                future: ModelService.getAvailableModels(),
                builder: (context, snapshot) {
                  final profiles = snapshot.data ?? [];
                  return ChatInput(
                    onSend: (text) => _sendMessage(text),
                    onCancel: _cancelGeneration,
                    isSending: _isSending,
                    selectedProfile: _selectedProfile,
                    allProfiles: profiles,
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
                    // Add new scroll button properties
                    showScrollButton: _showScrollToBottomButton,
                    onScrollToBottom: _scrollToBottomButtonPressed,
                  );
                },
              ),
            ],
          ),
          // Remove the floating button since we've moved it to the ChatInput
        ],
      ),
    );
  }
}