import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/model_profile.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isAssistant;
  final String assistantLabel;
  final Color accentColor;
  final bool isStreaming;
  final bool showRegenerateButton;
  final Function(ModelProfile, bool)? onRegenerateWithModel;
  final List<ModelProfile> availableModels;
  final bool useReasoning;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isAssistant,
    required this.assistantLabel,
    required this.accentColor,
    this.isStreaming = false,
    this.showRegenerateButton = false,
    this.onRegenerateWithModel,
    this.availableModels = const [],
    this.useReasoning = false,
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
            if (isStreaming && message.trim().isEmpty)
              const SizedBox.shrink()
            else if (message.trim().isNotEmpty)
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
              )
            else if (!isStreaming)
              const Text('No hay respuesta', style: TextStyle(color: Colors.grey)),
            if (isAssistant && isStreaming && message.trim().isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _ThinkingAnimation(accentColor: accentColor),
              ),
            if (isAssistant && !isStreaming && showRegenerateButton && onRegenerateWithModel != null && availableModels.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _RegenerateDropdown(
                    accentColor: accentColor,
                    availableModels: availableModels,
                    useReasoning: useReasoning,
                    onRegenerate: onRegenerateWithModel!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _ThinkingAnimation extends StatefulWidget {
  final Color accentColor;

  const _ThinkingAnimation({required this.accentColor});

  @override
  State<_ThinkingAnimation> createState() => _ThinkingAnimationState();
}

class _ThinkingAnimationState extends State<_ThinkingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);
            final scale = 0.6 + (opacity - 0.3) * 0.6;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withOpacity(opacity),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _RegenerateDropdown extends StatelessWidget {
  final Color accentColor;
  final List<ModelProfile> availableModels;
  final bool useReasoning;
  final Function(ModelProfile, bool) onRegenerate;

  const _RegenerateDropdown({
    required this.accentColor,
    required this.availableModels,
    required this.useReasoning,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh, size: 16, color: accentColor),
          const SizedBox(width: 4),
          Text('Regenerar', style: TextStyle(color: accentColor, fontSize: 13)),
          Icon(Icons.arrow_drop_down, size: 18, color: accentColor),
        ],
      ),
      offset: const Offset(0, -8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        
        // Modelos
        for (final model in availableModels) {
          items.add(
            PopupMenuItem<String>(
              value: 'model_${model.id}',
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [model.primaryColor, model.secondaryColor],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(model.displayName),
                ],
              ),
            ),
          );
        }
        
        return items;
      },
      onSelected: (value) {
        if (value.startsWith('model_')) {
          final modelId = value.substring(6);
          final model = availableModels.firstWhere((m) => m.id == modelId);
          onRegenerate(model, useReasoning);
        }
      },
    );
  }
}