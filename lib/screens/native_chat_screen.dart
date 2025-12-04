import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:docai/models/chat_message.dart';
import 'package:docai/models/chat_session.dart';
import 'package:docai/models/medical_preset.dart';
import 'package:docai/services/pollinations_service.dart';
import 'package:docai/screens/info_screen.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:docai/state/theme_scope.dart';

class NativeChatScreen extends StatefulWidget {
  const NativeChatScreen({super.key});

  @override
  State<NativeChatScreen> createState() => _NativeChatScreenState();
}

class _NativeChatScreenState extends State<NativeChatScreen>
    with TickerProviderStateMixin {
  final PollinationsService _service = PollinationsService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  MedicalPreset _selectedPreset = MedicalPreset.presets.first;
  bool _isLongResponse =
      false; // false = fast (512 tokens), true = long (2048 tokens)
  bool _isGenerating = false;
  bool _isIncognito = false;
  List<ChatSession> _chatHistory = [];
  String? _currentSessionId;
  int _currentPageIndex = 0; // 0 = chat, 1 = history
  bool _isNearBottom = true; // Track if user is near bottom

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_onScroll);
    _inputController.addListener(() {
      setState(() {}); // Rebuild when text changes for send button
    });

    FirebaseAnalytics.instance.logScreenView(screenName: 'home_screen');
  }

  @override
  void dispose() {
    _service.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final distanceFromBottom = maxScroll - offset;

      // Update near bottom status
      setState(() {
        _isNearBottom = distanceFromBottom < 100;
      });

      // Show/hide FAB based on scroll position
      if (distanceFromBottom > 200) {
        if (!_fabController.isCompleted) {
          _fabController.forward();
        }
      } else {
        if (_fabController.isCompleted) {
          _fabController.reverse();
        }
      }
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('chat_history') ?? [];

      setState(() {
        _chatHistory =
            historyJson
                .map((json) => ChatSession.fromJson(jsonDecode(json)))
                .toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    if (_isIncognito || _messages.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final session = ChatSession(
        id: _currentSessionId ?? const Uuid().v4(),
        messages: List.from(_messages),
        isLongResponse: _isLongResponse,
        preset: _selectedPreset.id,
        title: _generateTitle(),
      );

      _currentSessionId = session.id;

      final existingIndex = _chatHistory.indexWhere((s) => s.id == session.id);
      if (existingIndex != -1) {
        _chatHistory[existingIndex] = session;
      } else {
        _chatHistory.insert(0, session);
      }

      if (_chatHistory.length > 50) {
        _chatHistory = _chatHistory.sublist(0, 50);
      }

      final historyJson = _chatHistory
          .map((session) => jsonEncode(session.toJson()))
          .toList();

      await prefs.setStringList('chat_history', historyJson);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  String _generateTitle() {
    if (_messages.isEmpty) {
      return AppLocalizations.of(context)!.chatNewConversation;
    }

    final firstUserMessage = _messages.firstWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => _messages.first,
    );

    final title = firstUserMessage.content.substring(
      0,
      firstUserMessage.content.length > 50
          ? 50
          : firstUserMessage.content.length,
    );

    return title.length < firstUserMessage.content.length ? '$title...' : title;
  }

  void _loadChatSession(ChatSession session) {
    setState(() {
      _messages.clear();
      _messages.addAll(session.messages);
      _isLongResponse = session.isLongResponse;
      _selectedPreset = MedicalPreset.getById(session.preset);
      _currentSessionId = session.id;
      _isIncognito = false;
      _currentPageIndex = 0; // Switch back to chat page
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.user,
      content: text,
    );

    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
      _inputController.clear();
    });

    await FirebaseAnalytics.instance.logEvent(name: 'send_message');

    // Only auto-scroll if user was already near the bottom
    if (_isNearBottom) {
      _scrollToBottom();
    }

    final apiMessages = [
      {'role': 'system', 'content': _selectedPreset.systemPrompt},
      ..._messages.map((m) => m.toApiFormat()),
    ];

    try {
      final assistantMessage = ChatMessage(
        id: const Uuid().v4(),
        role: MessageRole.assistant,
        content: '',
      );

      setState(() {
        _messages.add(assistantMessage);
      });

      final response = await _service.generateText(
        messages: apiMessages,
        model: 'openai',
        temperature: 1.0,
        maxTokens: _isLongResponse ? 2048 : 512,
      );

      setState(() {
        final index = _messages.indexWhere((m) => m.id == assistantMessage.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: assistantMessage.id,
            role: MessageRole.assistant,
            content: response,
            timestamp: assistantMessage.timestamp,
          );
        }
      });

      await _saveChatHistory();
    } catch (e) {
      _showError('Error al generar respuesta: $e');

      final index = _messages.indexWhere(
        (m) => m.role == MessageRole.assistant && m.content.isEmpty,
      );
      if (index != -1) {
        setState(() {
          _messages.removeAt(index);
        });
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _currentSessionId = null;
      _isNearBottom = true;
    });
    // Reset FAB animation state
    if (_fabController.isCompleted) {
      _fabController.reverse();
    }
  }

  Future<void> _deleteAllChats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteDialogTitle),
        content: Text(AppLocalizations.of(context)!.deleteDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.deleteDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.deleteDialogConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _chatHistory.clear();
        _clearChat();
      });
      await _saveChatHistory(); // This will save the empty list
      await FirebaseAnalytics.instance.logEvent(name: 'delete_all_history');
    }
  }

  void _showPresetSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PresetSelectorSheet(
        selectedPreset: _selectedPreset,
        onPresetSelected: (preset) {
          // Always clear chat when selecting a preset (even if it's the same one)
          if (_messages.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => _ConfirmPresetChangeDialog(
                isSamePreset: preset.id == _selectedPreset.id,
                onConfirm: () {
                  setState(() {
                    _selectedPreset = preset;
                    _clearChat();
                  });
                  Navigator.of(context).pop();
                },
              ),
            );
          } else {
            setState(() {
              _selectedPreset = preset;
              _clearChat(); // Clear chat even if empty to reset session
            });
          }
        },
      ),
    );
  }

  void _switchToPage(int index) {
    setState(() {
      _currentPageIndex = index;
    });

    // Open preset selector only when switching to chat page (index 0) from history
    if (index == 0 && _currentPageIndex == 1) {
      // Don't open modal when returning from history
      FirebaseAnalytics.instance.logScreenView(screenName: 'home_screen');
    } else if (index == 1) {
      FirebaseAnalytics.instance.logScreenView(screenName: 'history_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: isLandscape
              ? Row(
                  children: [
                    _buildSideNav(localizations),
                    Expanded(child: _buildMainContent(localizations)),
                  ],
                )
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildMainContent(localizations)),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: MediaQuery.of(context).viewInsets.bottom == 0
                          ? _buildQuickActionsBar(localizations)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMainContent(AppLocalizations localizations) {
    return IndexedStack(
      index: _currentPageIndex,
      children: [
        // Chat page
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _messages.isEmpty
                      ? _WelcomeScreen(
                          preset: _selectedPreset,
                          onSuggestionTap: (suggestion) {
                            _inputController.text = suggestion;
                          },
                        )
                      : _buildMessagesList(),
                  // Scroll to bottom button positioned above input
                  if (_messages.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ScaleTransition(
                          scale: _fabAnimation,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green[400]!,
                                  Colors.green[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _scrollToBottom,
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildInputArea(localizations),
          ],
        ),

        // History page
        _buildHistoryPage(),
      ],
    );
  }

  Widget _buildSideNav(AppLocalizations localizations) {
    return Container(
      width: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Doky',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.add_comment_outlined),
                      tooltip: localizations.chatNewConversation,
                      onPressed: () {
                        FirebaseAnalytics.instance.logEvent(name: 'new_chat');
                        _clearChat();
                      },
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Text(
                        _selectedPreset.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      tooltip: _getPresetName(context, _selectedPreset),
                      onPressed: () {
                        if (_currentPageIndex != 0) {
                          _switchToPage(0);
                        } else {
                          _showPresetSelector();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(
                        Icons.history_outlined,
                        color: _currentPageIndex == 1
                            ? Colors.green[700]
                            : Colors.grey[700],
                      ),
                      tooltip: localizations.menuHistory,
                      onPressed: () => _switchToPage(1),
                    ),
                    if (_currentPageIndex == 1 && _chatHistory.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: localizations.deleteDialogConfirm,
                        onPressed: _deleteAllChats,
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isIncognito ? Icons.visibility_off : Icons.visibility,
                        color: _isIncognito ? Colors.amber[700] : null,
                      ),
                      tooltip: _isIncognito
                          ? 'Incognito Mode ON'
                          : 'Incognito Mode OFF',
                      onPressed: () {
                        setState(() => _isIncognito = !_isIncognito);
                      },
                    ),
                    const SizedBox(height: 8),
                    // Theme toggle
                    IconButton(
                      icon: Icon(
                        ThemeScope.of(context).themeMode == ThemeMode.system
                            ? Icons.brightness_auto
                            : ThemeScope.of(context).themeMode ==
                                  ThemeMode.light
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      tooltip:
                          ThemeScope.of(context).themeMode == ThemeMode.system
                          ? 'System Theme'
                          : ThemeScope.of(context).themeMode == ThemeMode.light
                          ? 'Light Theme'
                          : 'Dark Theme',
                      onPressed: () {
                        ThemeScope.of(context).toggleTheme();
                      },
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Info',
                      onPressed: () {
                        FirebaseAnalytics.instance.logScreenView(
                          screenName: 'info_screen',
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const InfoScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Doky',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (_currentPageIndex == 1 && _chatHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: AppLocalizations.of(context)!.deleteDialogConfirm,
              onPressed: _deleteAllChats,
            ),
          // Incognito mode toggle
          IconButton(
            icon: Icon(
              _isIncognito ? Icons.visibility_off : Icons.visibility,
              color: _isIncognito ? Colors.amber[700] : null,
            ),
            tooltip: _isIncognito ? 'Incognito Mode ON' : 'Incognito Mode OFF',
            onPressed: () {
              setState(() => _isIncognito = !_isIncognito);
            },
          ),
          IconButton(
            icon: Icon(
              ThemeScope.of(context).themeMode == ThemeMode.system
                  ? Icons.brightness_auto
                  : ThemeScope.of(context).themeMode == ThemeMode.light
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: ThemeScope.of(context).themeMode == ThemeMode.system
                ? 'System Theme'
                : ThemeScope.of(context).themeMode == ThemeMode.light
                ? 'Light Theme'
                : 'Dark Theme',
            onPressed: () {
              ThemeScope.of(context).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: AppLocalizations.of(context)!.chatNewConversation,
            onPressed: () {
              FirebaseAnalytics.instance.logEvent(name: 'new_chat');
              _clearChat();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
            onPressed: () {
              FirebaseAnalytics.instance.logScreenView(
                screenName: 'info_screen',
              );
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const InfoScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message.role == MessageRole.user;
        final showAvatar =
            index == 0 || _messages[index - 1].role != message.role;

        return _MessageCard(
          message: message,
          isUser: isUser,
          showAvatar: showAvatar,
          isGenerating:
              _isGenerating &&
              index == _messages.length - 1 &&
              message.role == MessageRole.assistant,
        );
      },
    );
  }

  Widget _buildInputArea(AppLocalizations localizations) {
    final hasText = _inputController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                enabled: !_isGenerating,
                style: const TextStyle(fontSize: 15),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: localizations.inputPlaceholder,
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (hasText) ...[
            // Response length toggle button
            _buildResponseLengthToggle(),
            const SizedBox(width: 8),
            // Send button
            _buildSendButton(),
          ] else ...[
            // Voice button (placeholder)
            _buildVoiceButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isGenerating
              ? [
                  isDark ? Colors.grey[700]! : Colors.grey[400]!,
                  isDark ? Colors.grey[600]! : Colors.grey[500]!,
                ]
              : [
                  isDark ? Colors.green[700]! : Colors.green[400]!,
                  isDark ? Colors.green[900]! : Colors.green[600]!,
                ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          if (!_isGenerating)
            BoxShadow(
              color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isGenerating ? Icons.hourglass_empty : Icons.send_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: _isGenerating ? null : _sendMessage,
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.mic_none, size: 22),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice input coming soon!')),
          );
        },
      ),
    );
  }

  Widget _buildResponseLengthToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = _isLongResponse ? Colors.blue : Colors.green;
    final backgroundColor = isDark
        ? activeColor.withValues(alpha: 0.2)
        : (_isLongResponse ? Colors.blue[100] : Colors.green[100]);
    final iconColor = isDark
        ? activeColor[300]
        : (_isLongResponse ? Colors.blue[700] : Colors.green[700]);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isLongResponse ? Icons.article : Icons.bolt,
          color: iconColor,
          size: 20,
        ),
        tooltip: _isLongResponse ? 'Long Response' : 'Fast Response',
        onPressed: () {
          setState(() => _isLongResponse = !_isLongResponse);
        },
      ),
    );
  }

  Widget _buildHistoryPage() {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: _chatHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 24),
                      Text(
                        localizations.chatNoHistory,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.chatHistoryPlaceholder,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final session = _chatHistory[index];
                    return Dismissible(
                      key: Key(session.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() {
                          _chatHistory.remove(session);
                          if (_currentSessionId == session.id) {
                            _clearChat();
                          }
                        });
                        _saveChatHistory();
                        // Snackbar removed as requested
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _loadChatSession(session),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      MedicalPreset.getById(
                                        session.preset,
                                      ).emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        session.title ??
                                            localizations.chatUntitled,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${session.messages.length} messages',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      timeago.format(
                                        session.updatedAt,
                                        locale: Localizations.localeOf(
                                          context,
                                        ).languageCode,
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsBar(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickActionButton(
            icon: Icons.medical_services_outlined,
            label: _getPresetName(context, _selectedPreset),
            emoji: _selectedPreset.emoji,
            isActive: _currentPageIndex == 0,
            onTap: () {
              if (_currentPageIndex != 0) {
                _switchToPage(0);
              } else {
                _showPresetSelector();
              }
            },
          ),
          _QuickActionButton(
            icon: Icons.history_outlined,
            label: localizations.menuHistory,
            isActive: _currentPageIndex == 1,
            onTap: () => _switchToPage(1),
          ),
        ],
      ),
    );
  }

  String _getPresetName(BuildContext context, MedicalPreset preset) {
    final loc = AppLocalizations.of(context)!;
    switch (preset.id) {
      case 'general':
        return loc.presetGeneralName;
      case 'diagnostico':
        return loc.presetDiagnosisName;
      case 'sintomas':
        return loc.presetSymptomsName;
      case 'medicacion':
        return loc.presetMedicationName;
      case 'nutricion':
        return loc.presetNutritionName;
      case 'ejercicio':
        return loc.presetExerciseName;
      default:
        return preset.name;
    }
  }
}

// Message Card Widget
class _MessageCard extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final bool showAvatar;
  final bool isGenerating;

  const _MessageCard({
    required this.message,
    required this.isUser,
    required this.showAvatar,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final useMobileLayout = !isUser && isMobile;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: useMobileLayout
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAvatar) ...[
                    Row(
                      children: [
                        _buildAvatar(),
                        const SizedBox(width: 8),
                        Text(
                          localizations.chatDoky,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  _buildMessageBubble(context),
                  _buildTimestamp(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!isUser && showAvatar) ...[
                    _buildAvatar(),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showAvatar) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 6,
                              left: 4,
                              right: 4,
                            ),
                            child: Text(
                              isUser
                                  ? localizations.chatYou
                                  : localizations.chatDoky,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                        _buildMessageBubble(context),
                        _buildTimestamp(),
                      ],
                    ),
                  ),
                  if (isUser && showAvatar) ...[
                    const SizedBox(width: 12),
                    _buildAvatar(),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userBubbleColor = isDark ? Colors.green[800] : Colors.green[500];
    final assistantBubbleColor = isDark ? Colors.grey[800] : Colors.white;
    final codeBackgroundColor = isDark ? Colors.black26 : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUser ? userBubbleColor : assistantBubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: message.content.isEmpty && isGenerating
          ? _buildTypingIndicator()
          : isUser
          ? Text(
              message.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            )
          : MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isDark ? Colors.grey[200] : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
                code: TextStyle(
                  backgroundColor: codeBackgroundColor,
                  color: isDark ? Colors.green[300] : Colors.green[700],
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: codeBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
    );
  }

  Widget _buildTimestamp() {
    if (isGenerating) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Text(
        timeago.format(message.timestamp),
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isUser ? Colors.green[100] : Colors.green[100],
        shape: BoxShape.circle,
        border: Border.all(
          color: isUser ? Colors.green[200]! : Colors.green[200]!,
          width: 2,
        ),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.medical_services,
        color: isUser ? Colors.green[700] : Colors.green[700],
        size: 20,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, double value, child) {
            return Opacity(
              opacity: (value + index * 0.3).clamp(0, 1),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

// Welcome Screen Widget
class _WelcomeScreen extends StatelessWidget {
  final MedicalPreset preset;
  final ValueChanged<String> onSuggestionTap;

  const _WelcomeScreen({required this.preset, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final suggestions = _getSuggestions(context);

    if (isLandscape) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Logo and Info
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(context),
                    const SizedBox(height: 24),
                    Text(
                      '${preset.emoji} ${_getPresetName(context, preset)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getPresetDescription(context, preset),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      localizations.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Right side: Suggestions in 2 columns
              Expanded(
                flex: 5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: suggestions.map((suggestion) {
                        return SizedBox(
                          width: (constraints.maxWidth - 12) / 2,
                          child: _SuggestionChip(
                            text: suggestion,
                            onTap: () => onSuggestionTap(suggestion),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(context),
            const SizedBox(height: 32),
            Text(
              '${preset.emoji} ${_getPresetName(context, preset)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getPresetDescription(context, preset),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              localizations.welcomeTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.welcomeSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ...suggestions.map((suggestion) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SuggestionChip(
                  text: suggestion,
                  onTap: () => onSuggestionTap(suggestion),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.green[900]!.withValues(alpha: 0.3)
              : Colors.green[50],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/logo/logo compress.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  List<String> _getSuggestions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (preset.id) {
      case 'diagnostico':
        return [
          localizations.suggestionDiagnosis1,
          localizations.suggestionDiagnosis2,
          localizations.suggestionDiagnosis3,
        ];
      case 'sintomas':
        return [
          localizations.suggestionSymptoms1,
          localizations.suggestionSymptoms2,
          localizations.suggestionSymptoms3,
        ];
      case 'medicacion':
        return [
          localizations.suggestionMedication1,
          localizations.suggestionMedication2,
          localizations.suggestionMedication3,
        ];
      case 'nutricion':
        return [
          localizations.suggestionNutrition1,
          localizations.suggestionNutrition2,
          localizations.suggestionNutrition3,
        ];
      case 'ejercicio':
        return [
          localizations.suggestionExercise1,
          localizations.suggestionExercise2,
          localizations.suggestionExercise3,
        ];
      case 'general':
      default:
        return [
          localizations.suggestionGeneral1,
          localizations.suggestionGeneral2,
          localizations.suggestionGeneral3,
        ];
    }
  }

  String _getPresetName(BuildContext context, MedicalPreset preset) {
    final loc = AppLocalizations.of(context)!;
    switch (preset.id) {
      case 'general':
        return loc.presetGeneralName;
      case 'diagnostico':
        return loc.presetDiagnosisName;
      case 'sintomas':
        return loc.presetSymptomsName;
      case 'medicacion':
        return loc.presetMedicationName;
      case 'nutricion':
        return loc.presetNutritionName;
      case 'ejercicio':
        return loc.presetExerciseName;
      default:
        return preset.name;
    }
  }

  String _getPresetDescription(BuildContext context, MedicalPreset preset) {
    final loc = AppLocalizations.of(context)!;
    switch (preset.id) {
      case 'general':
        return loc.presetGeneralDesc;
      case 'diagnostico':
        return loc.presetDiagnosisDesc;
      case 'sintomas':
        return loc.presetSymptomsDesc;
      case 'medicacion':
        return loc.presetMedicationDesc;
      case 'nutricion':
        return loc.presetNutritionDesc;
      case 'ejercicio':
        return loc.presetExerciseDesc;
      default:
        return preset.description;
    }
  }
}

// Suggestion Chip Widget
class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.green[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
          ],
        ),
      ),
    );
  }
}

// Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? emoji;
  final VoidCallback onTap;
  final bool isActive;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.emoji,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.green[900]!.withValues(alpha: 0.3)
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 24)),
              ] else ...[
                Icon(
                  icon,
                  size: 24,
                  color: isActive
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.green[300]
                            : Colors.green[700])
                      : null,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.green[300]
                            : Colors.green[700])
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Preset Selector Sheet
class _PresetSelectorSheet extends StatelessWidget {
  final MedicalPreset selectedPreset;
  final ValueChanged<MedicalPreset> onPresetSelected;

  const _PresetSelectorSheet({
    required this.selectedPreset,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '🩺 ${AppLocalizations.of(context)!.medicalSpecialty}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: isLandscape
                ? GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: MedicalPreset.presets.length,
                    itemBuilder: (context, index) {
                      final preset = MedicalPreset.presets[index];
                      return _buildPresetItem(context, preset, true);
                    },
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: MedicalPreset.presets.map((preset) {
                      return _buildPresetItem(context, preset, false);
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPresetItem(
    BuildContext context,
    MedicalPreset preset,
    bool isGrid,
  ) {
    final isSelected = preset.id == selectedPreset.id;
    return Container(
      margin: isGrid
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.green[900]!.withValues(alpha: 0.3)
                  : Colors.green[50])
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.green[700]!
                    : Colors.green[300]!)
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pop(context);
          onPresetSelected(preset);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isGrid
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(preset.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      _getPresetName(context, preset),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 16,
                      ),
                    ],
                  ],
                )
              : Row(
                  children: [
                    Text(preset.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPresetName(context, preset),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPresetDescription(context, preset),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: Colors.green[600]),
                  ],
                ),
        ),
      ),
    );
  }

  String _getPresetName(BuildContext context, MedicalPreset preset) {
    final loc = AppLocalizations.of(context)!;
    switch (preset.id) {
      case 'general':
        return loc.presetGeneralName;
      case 'diagnostico':
        return loc.presetDiagnosisName;
      case 'sintomas':
        return loc.presetSymptomsName;
      case 'medicacion':
        return loc.presetMedicationName;
      case 'nutricion':
        return loc.presetNutritionName;
      case 'ejercicio':
        return loc.presetExerciseName;
      default:
        return preset.name;
    }
  }

  String _getPresetDescription(BuildContext context, MedicalPreset preset) {
    final loc = AppLocalizations.of(context)!;
    switch (preset.id) {
      case 'general':
        return loc.presetGeneralDesc;
      case 'diagnostico':
        return loc.presetDiagnosisDesc;
      case 'sintomas':
        return loc.presetSymptomsDesc;
      case 'medicacion':
        return loc.presetMedicationDesc;
      case 'nutricion':
        return loc.presetNutritionDesc;
      case 'ejercicio':
        return loc.presetExerciseDesc;
      default:
        return preset.description;
    }
  }
}

// Confirm Preset Change Dialog
class _ConfirmPresetChangeDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isSamePreset;

  const _ConfirmPresetChangeDialog({
    required this.onConfirm,
    this.isSamePreset = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isSamePreset
            ? AppLocalizations.of(context)!.dialogNewChatTitle
            : AppLocalizations.of(context)!.dialogChangeSpecialtyTitle,
      ),
      content: Text(
        isSamePreset
            ? AppLocalizations.of(context)!.dialogNewChatContent
            : AppLocalizations.of(context)!.dialogChangeSpecialtyContent,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.dialogCancel),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(
            isSamePreset
                ? AppLocalizations.of(context)!.dialogConfirmNewChat
                : AppLocalizations.of(context)!.dialogConfirmChange,
          ),
        ),
      ],
    );
  }
}
