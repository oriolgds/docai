import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isAssistant;
  final String assistantLabel;
  final Color accentColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isAssistant,
    required this.assistantLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isAssistant ? const Color(0xFFF5F5F5) : const Color(0xFF000000);
    final fg = isAssistant ? Colors.black : Colors.white;

    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isAssistant ? 2 : 14),
            bottomRight: Radius.circular(isAssistant ? 14 : 2),
          ),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment:
              isAssistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (isAssistant)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      assistantLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: TextStyle(color: fg, fontSize: 15, height: 1.35),
                code: TextStyle(
                  backgroundColor: isAssistant ? Colors.white : Colors.black,
                  color: isAssistant ? Colors.black : Colors.white,
                ),
              ),
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }
}
