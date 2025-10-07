import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../services/openrouter_service.dart';
import '../../services/chat_state_manager.dart';
import '../../services/chat_history_service.dart';
import '../../services/model_service.dart';
import '../../models/model_profile.dart';
import '../../exceptions/model_exceptions.dart';
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';
import '../../models/user_medical_preferences.dart';
import '../../config/openrouter_config.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../services/medical_data_bridge_service.dart';
import '../../services/medical_preferences_service.dart';

import '../medical_preferences_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

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
  final ChatHistoryService _historyService = ChatHistoryService();
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
  UserMedicalPreferences? _userMedicalPreferences;
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

    // Verificar si la conversación actual ha sido actualizada (ej. título cambió)
    if (_conversationId != null) {
      final updatedConversation = _stateManager.getConversationById(_conversationId!);
      if (updatedConversation != null && 
          (updatedConversation.title != _currentConversation?.title || 
           updatedConversation.updatedAt != _currentConversation?.updatedAt)) {
        debugPrint('[DEBUG] ChatScreen: Conversation updated - Title: ${updatedConversation.title}');
        setState(() {
          _currentConversation = updatedConversation;
        });
      }
    }
  }

  Future<void> _checkFirstTimeUser() async {
    try {
      final medicalService = MedicalPreferencesService();
      final medicalPrefs = await medicalService.getUserMedicalPreferences();
      final isFirstTime = medicalPrefs == null;
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
      // Load the user medical preferences for chat
      final medicalService = MedicalPreferencesService();
      final preferences = await medicalService.getUserMedicalPreferences();
      if (mounted) {
        setState(() {
          _userMedicalPreferences = preferences;
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

    if (_userMedicalPreferences == null) {
      return basePrompt;
    }

    List<String> personalizations = [];

    // Agregar información sobre alergias
    if (_userMedicalPreferences!.allergies.isNotEmpty) {
      personalizations.add(
        'IMPORTANTE: El usuario tiene las siguientes alergias: ${_userMedicalPreferences!.allergies.join(", ")}. '
        'SIEMPRE considera estas alergias al dar recomendaciones médicas, medicamentos o tratamientos.'
      );
    }

    // Agregar alergias a medicamentos
    if (_userMedicalPreferences!.medicationAllergies.isNotEmpty) {
      personalizations.add(
        'IMPORTANTE: El usuario tiene alergias a los siguientes medicamentos: ${_userMedicalPreferences!.medicationAllergies.join(", ")}. '
        'NUNCA recomiendes estos medicamentos.'
      );
    }

    // Agregar preferencia de medicina
    if (_userMedicalPreferences!.medicinePreference != 'both') {
      String preferenceText = _userMedicalPreferences!.medicinePreference == 'natural'
          ? 'El usuario prefiere medicina natural y remedios alternativos'
          : 'El usuario prefiere medicina convencional y tratamientos farmacológicos';
      personalizations.add('$preferenceText. Ajusta tus recomendaciones según esta preferencia.');
    }

    // Agregar condiciones crónicas
    if (_userMedicalPreferences!.chronicConditions.isNotEmpty) {
      personalizations.add(
        'El usuario tiene las siguientes condiciones crónicas: ${_userMedicalPreferences!.chronicConditions.join(", ")}. '
        'Ten en cuenta estas condiciones al proporcionar consejos médicos.'
      );
    }

    // Agregar medicamentos actuales
    if (_userMedicalPreferences!.currentMedications.isNotEmpty) {
      personalizations.add(
        'El usuario toma actualmente los siguientes medicamentos: ${_userMedicalPreferences!.currentMedications.join(", ")}. '
        'Verifica posibles interacciones medicamentosas antes de recomendar nuevos tratamientos.'
      );
    }

    // Agregar información de edad calculada de dateOfBirth
    if (_userMedicalPreferences!.dateOfBirth != null) {
      final age = DateTime.now().difference(_userMedicalPreferences!.dateOfBirth!).inDays ~/ 365;
      String ageRange;
      if (age < 18) ageRange = 'menor de 18 años';
      else if (age < 36) ageRange = '18-35 años';
      else if (age < 56) ageRange = '36-55 años';
      else if (age < 76) ageRange = '56-75 años';
      else ageRange = 'más de 75 años';
      personalizations.add('El usuario tiene $age años (rango: $ageRange).');
    }

    // Agregar género
    if (_userMedicalPreferences!.gender != null && _userMedicalPreferences!.gender != 'prefer_not_to_say') {
      String genderText;
      switch (_userMedicalPreferences!.gender) {
        case 'male': genderText = 'Masculino'; break;
        case 'female': genderText = 'Femenino'; break;
        case 'other': genderText = 'Otro'; break;
        default: genderText = _userMedicalPreferences!.gender!;
      }
      personalizations.add('Género del usuario: $genderText.');
    }

    // Agregar información adicional si está disponible
    if (_userMedicalPreferences!.smokingStatus != 'never') {
      personalizations.add('Hábitos de tabaquismo: ${_userMedicalPreferences!.smokingStatus}.');
    }

    if (_userMedicalPreferences!.alcoholConsumption != 'never') {
      personalizations.add('Consumo de alcohol: ${_userMedicalPreferences!.alcoholConsumption}.');
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
    }
    
    // Solo actualizar y guardar la conversación si tenemos mensajes
    if (_messages.isNotEmpty && _currentConversation != null) {
      // Actualizar la conversación con los mensajes actuales
      final updatedConversation = _currentConversation!.copyWith(
        messages: List.from(_messages),
        updatedAt: DateTime.now(),
      );
      
      await _stateManager.saveConversation(updatedConversation);
      _currentConversation = updatedConversation;
    }
  }

  Future<void> _generateAndUpdateTitle(String firstUserMessage) async {
    if (_currentConversation == null) return;
    
    try {
      debugPrint('[DEBUG] ChatScreen: Generating title for conversation ${_currentConversation!.id}');
      final newTitle = await _historyService.generateConversationTitle(firstUserMessage);
      
      final updatedConversation = _currentConversation!.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      
      await _stateManager.saveConversation(updatedConversation);
      
      if (mounted) {
        setState(() {
          _currentConversation = updatedConversation;
        });
        debugPrint('[DEBUG] ChatScreen: Title updated in UI: $newTitle');
      }
    } catch (e) {
      debugPrint('[DEBUG] ChatScreen: Failed to generate title: $e');
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

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C5CE7), size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // Modal para configurar clave API BYOK
  Future<void> _showApiKeySetupModal() async {
    final l10n = AppLocalizations.of(context)!;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // No permitir cerrar tocando fuera
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.key,
                  color: Color(0xFF6C5CE7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Configura tu clave API',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para usar DocAI, necesitas configurar tu propia clave API de OpenRouter:',
                style: TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem('Acceso completo a DocAI', Icons.check_circle),
              _buildFeatureItem('Sin límites de uso', Icons.all_inclusive),
              _buildFeatureItem('Mejor rendimiento', Icons.speed),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEB3B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFEB3B).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Es obligatorio configurar una clave API personal.',
                        style: TextStyle(
                          color: Color(0xFF6C757D),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // Cerrar modal actual
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(scrollToApiKey: true),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Ir al Perfil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C5CE7),
                      side: const BorderSide(color: Color(0xFF6C5CE7)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);

                            try {
                              // Navegar directamente al perfil
                              Navigator.pop(context); // Cerrar modal actual
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: const Color(0xFFE74C3C),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.settings, size: 16),
                    label: const Text('Configurar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(
    String text, {
    int? regenerateIndex,
    ModelProfile? overrideProfile,
    bool? overrideReasoning,
  }) async {
    // Verificar si el usuario tiene BYOK configurado
    final hasApiKey = await SupabaseService.hasUserApiKey('openrouter');
    if (!hasApiKey) {
      await _showApiKeySetupModal();
      return; // No continuar con el envío del mensaje
    }

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
            
            // Generar título síncrono si es el primer mensaje del usuario
            if (!_hasFirstMessage || _currentConversation!.title == 'Nueva conversación') {
              await _generateAndUpdateTitle(text);
            }
          }
        },
        onError: (e) {
          _currentStreamSubscription = null;

          if (mounted) {
            // Check if it's a BYOK error
            if (e.toString().contains('No API key configured')) {
              // Show BYOK setup modal
              _showApiKeySetupModal();
            } else {
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
        // Check if it's a BYOK error
        if (e.toString().contains('No API key configured')) {
          // Show BYOK setup modal
          await _showApiKeySetupModal();
        } else {
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

  Future<void> _regenerateWithModel(int assistantIndex, ModelProfile model, bool reasoning) async {
    if (_isSending) return;
    if (assistantIndex <= 0) return;
    if (_messages[assistantIndex - 1].role != ChatRole.user) return;
    
    final userMessage = _messages[assistantIndex - 1];
    
    setState(() {
      _selectedProfile = model;
      _useReasoning = reasoning;
    });
    
    await _sendMessage(
      userMessage.content,
      regenerateIndex: assistantIndex - 1,
      overrideProfile: model,
      overrideReasoning: reasoning,
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
                                    onTap: () => setState(() => _showFirstTimeWarning = false),
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
                                    onPressed: () => setState(() => _showFirstTimeWarning = false),
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

                      return FutureBuilder<List<ModelProfile>>(
                        future: ModelService.getAvailableModels(),
                        builder: (context, snapshot) {
                          final models = snapshot.data ?? [];
                          return MessageBubble(
                            message: m.content,
                            isAssistant: isAssistant,
                            assistantLabel: _assistantLabel(),
                            accentColor: _selectedProfile.primaryColor,
                            isStreaming:
                                isAssistant &&
                                _streamingIndex != null &&
                                messageIndex == _streamingIndex,
                            showRegenerateButton: isAssistant && !isWelcomeMessage && messageIndex > 0,
                            onRegenerateWithModel: isAssistant && !isWelcomeMessage && messageIndex > 0
                                ? (model, reasoning) => _regenerateWithModel(messageIndex, model, reasoning)
                                : null,
                            availableModels: models,
                            useReasoning: _useReasoning,
                          );
                        },
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