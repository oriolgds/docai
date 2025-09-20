import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isAssistant;
  final String assistantLabel;
  final Color accentColor;
  final bool isStreaming;
  final VoidCallback? onRegenerate;
  final bool showRegenerateButton;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isAssistant,
    required this.assistantLabel,
    required this.accentColor,
    this.isStreaming = false,
    this.onRegenerate,
    this.showRegenerateButton = false,
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
            if (message.trim().isNotEmpty)
              MarkdownBody(
                data: message,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: TextStyle(color: fg, fontSize: 15, height: 1.35),
                  code: TextStyle(
                    backgroundColor: isAssistant ? Colors.white : Colors.black,
                    color: isAssistant ? Colors.black : Colors.white,
                  ),
                ),
                selectable: true,
              ),
            if (isAssistant && isStreaming)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pensando...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            if (isAssistant && !isStreaming && showRegenerateButton && onRegenerate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRegenerate,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Regenerar'),
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
