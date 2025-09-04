import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final _scrollController = ScrollController();

  final List<String> _presets = [
    'Medications',
    'Natural Remedies',
    'Symptoms Check',
    'First Aid',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocAI Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Presets
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_presets[index]),
                    onSelected: (selected) => _selectPreset(_presets[index]),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                );
              },
            ),
          ),
          
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: Color(0xFFE0E0E0),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Ask me anything about your health',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'I\'m here to help with medical questions,\nsymptoms, and health advice.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about your health...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.black : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.black,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "I understand you're asking about '$text'. As an AI doctor, I'd recommend consulting with a healthcare professional for personalized advice. However, I can provide general information to help you understand your concern better.",
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
  }

  void _selectPreset(String preset) {
    _messageController.text = "Tell me about $preset";
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}