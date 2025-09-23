import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input.dart';
import '../../widgets/chat/model_selector.dart';
import '../../services/openrouter_service.dart';
import '../../services/medical_preferences_service.dart';
import '../../models/model_profile.dart';
import '../../models/chat_message.dart';
import '../../config/openrouter_config.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late ModelProfile _selectedProfile;
  bool _isSending = false;
  late OpenRouterService _service;
  final MedicalPreferencesService _medicalService = MedicalPreferencesService();
  bool _showDisclaimer = true;
  int? _streamingIndex;
  Timer? _scrollTimer;
  bool _shouldScroll = false;
  bool _useReasoning = false;
  String _medicalContext = '';

  @override
  void initState() {
    super.initState();
    _service = OpenRouterService();
    _selectedProfile = ModelProfile.defaultProfile;
    _loadMedicalContext();
    _addInitialAssistantMessage();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalContext() async {
    try {
      _medicalContext = await _medicalService.getMedicalContext();
    } catch (e) {
      _medicalContext = OpenRouterConfig.disclaimerText;
    }
  }

  String _assistantLabel() {
    final baseName = brandDisplayName(_selectedProfile.brand);
    return _useReasoning ? '$baseName • Razonamiento' : baseName;
  }

  void _addInitialAssistantMessage() {
    _messages.add(ChatMessage.assistant(
        'Hola, soy Gaia, tu asistente médico AI. ¿En qué puedo ayudarte hoy?\n\n'
        '💡 **Recuerda:** DocAI no sustituye el consejo médico profesional. '
        'Para diagnósticos, tratamientos o emergencias, acude a un profesional de la salud.'));
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
        if (regenerateIndex >= 0 && regenerateIndex < _messages.length - 1) {
          _messages.removeRange(regenerateIndex + 1, _messages.length);
        }
      }
      _isSending = true;
      _showDisclaimer = false;
    });
    
    await Future.delayed(Duration.zero);
    await _scrollToBottom(force: true);

    try {
      final historyAll = _messages
          .where((m) => m.role != ChatRole.system)
          .toList();
      final history = historyAll.length > 24
          ? historyAll.sublist(historyAll.length - 24)
          : historyAll;
      
      setState(() {
        _messages.add(ChatMessage.assistant(''));
        _streamingIndex = _messages.length - 1;
      });
      
      await Future.delayed(Duration.zero);
      await _scrollToBottom(force: true);

      final stream = _service.streamChatCompletion(
        messages: history,
        profile: overrideProfile ?? _selectedProfile,
        useReasoning: overrideReasoning ?? _useReasoning,
      );

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

        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (maxScroll - currentScroll < 300) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ));
        if (_streamingIndex != null && _streamingIndex! < _messages.length) {
          setState(() {
            _messages[_streamingIndex!] = ChatMessage(
              id: _messages[_streamingIndex!].id,
              role: ChatRole.assistant,
              content:
                  'Lo siento, ha ocurrido un error. Por favor, inténtalo de nuevo.\n\n'
                  '⚠️ **Recuerda:** Si tienes una emergencia médica, contacta inmediatamente con servicios de emergencia.',
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

    _scrollTimer?.cancel();
    await Future.delayed(Duration.zero);

    if (force || !_scrollController.position.outOfRange) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } else {
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
                      const Text('Razonamiento médico avanzado'),
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
                        'Gaia proporcionará un análisis médico paso a paso más detallado, '
                        'considerando tu perfil médico personalizado.',
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

  void _showMedicalPreferencesInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Personalización Médica'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_medicalContext.isNotEmpty 
                ? 'Tu perfil médico personalizado está activo. Gaia tendrá en cuenta tus preferencias y condiciones médicas.'
                : 'No tienes un perfil médico configurado. Ve a tu perfil para personalizar DocAI.'),
            const SizedBox(height: 16),
            if (_medicalContext.isEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Configurar Perfil'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = brandColor(_selectedProfile.brand);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docai'),
        actions: [
          IconButton(
            tooltip: 'Personalización médica',
            icon: Icon(
              Icons.medical_services,
              color: _medicalContext.isNotEmpty ? Colors.blue : Colors.grey,
            ),
            onPressed: _showMedicalPreferencesInfo,
          ),
          IconButton(
            tooltip: 'Aviso médico',
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
          if (_showDisclaimer)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_hospital_outlined, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      OpenRouterConfig.disclaimerText,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _showDisclaimer = false),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                Widget _buildMessageBubble(ChatMessage message, int index) {
                  final isAssistant = message.role == ChatRole.assistant;
                  final isWelcomeMessage = index == 0 && isAssistant;

                  return MessageBubble(
                    message: message.content,
                    isAssistant: isAssistant,
                    assistantLabel: _assistantLabel(),
                    accentColor: brandColor(_selectedProfile.brand),
                    isStreaming:
                        isAssistant &&
                        _streamingIndex != null &&
                        index == _streamingIndex,
                    showRegenerateButton: isAssistant && !isWelcomeMessage,
                    onRegenerate: isAssistant && !isWelcomeMessage
                        ? () {
                            _regenerateResponse(index);
                          }
                        : null,
                  );
                }

                return _buildMessageBubble(m, index);
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
