import 'package:flutter/material.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input.dart';
import '../../services/openrouter_service.dart';
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
  bool _showDisclaimer = true;

  @override
  void initState() {
    super.initState();
    _service = OpenRouterService();
    _selectedProfile = ModelProfile.defaultProfile;
    _addInitialAssistantMessage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  String _assistantLabel() =>
      '${brandDisplayName(_selectedProfile.brand)} • ${_selectedProfile.tier}';

  void _addInitialAssistantMessage() {
    final label = _assistantLabel();
    _messages.add(ChatMessage.assistant(
        'Hola, soy $label. ¿En qué puedo ayudarte hoy?'));
  }

  Future<void> _sendMessage(String text) async {
    setState(() {
      _messages.add(ChatMessage.user(text));
      _isSending = true;
      _showDisclaimer = false;
    });
    _scrollToBottom();

    try {
      final historyAll = _messages
          .where((m) => m.role != ChatRole.system)
          .toList();
      final history = historyAll.length > 24
          ? historyAll.sublist(historyAll.length - 24)
          : historyAll;
      final reply = await _service.chatCompletion(
        messages: history,
        profile: _selectedProfile,
      );
      setState(() {
        _messages.add(ChatMessage.assistant(reply));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showProModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.workspace_premium, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Desbloquea Heynos Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Accede a respuestas más profundas y razonamiento avanzado. Ideal para casos complejos y explicaciones detalladas.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Razonamiento de nivel profesional', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Respuestas más completas y útiles', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                        child: const Text('Ir a suscripción Pro'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = brandColor(_selectedProfile.brand);
    return Scaffold(
      appBar: AppBar(
        title: Text('DocAI ${brandDisplayName(_selectedProfile.brand)}'),
        actions: [
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
                final isAssistant = m.role == ChatRole.assistant;
                return MessageBubble(
                  message: m,
                  isAssistant: isAssistant,
                  assistantLabel: _assistantLabel(),
                  accentColor: accent,
                );
              },
            ),
          ),
          ChatInput(
            onSend: _sendMessage,
            isSending: _isSending,
            selectedProfile: _selectedProfile,
            allProfiles: ModelProfile.defaults(),
            onProfileChanged: (p) {
              setState(() {
                _selectedProfile = p;
              });
            },
            onRequestPro: _showProModal,
          ),
        ],
      ),
    );
  }
}
