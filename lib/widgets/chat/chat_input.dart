import 'package:flutter/material.dart';
import '../../models/model_profile.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isSending;
  final ModelProfile selectedProfile;
  final List<ModelProfile> allProfiles;
  final ValueChanged<ModelProfile> onProfileChanged;
  final VoidCallback onRequestPro;
  final bool useReasoning;
  final ValueChanged<bool> onReasoningChanged;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isSending = false,
    required this.selectedProfile,
    required this.allProfiles,
    required this.onProfileChanged,
    required this.onRequestPro,
    this.useReasoning = false,
    required this.onReasoningChanged,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.selectedProfile;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model selector row with reasoning toggle
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: _ModelDisplay(
                      selected: current,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón de razonamiento
                  _ReasoningToggle(
                    useReasoning: widget.useReasoning,
                    onChanged: widget.onReasoningChanged,
                    accentColor: brandColor(current.brand),
                  ),
                ],
              ),
            ),
            
            // Text input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu consulta médica...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                Container(
                  margin: const EdgeInsets.only(bottom: 4), // Align with text field
                  child: IconButton.filled(
                    onPressed: widget.isSending ? null : _submit,
                    style: IconButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: widget.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    tooltip: 'Enviar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasoningToggle extends StatelessWidget {
  final bool useReasoning;
  final ValueChanged<bool> onChanged;
  final Color accentColor;

  const _ReasoningToggle({
    required this.useReasoning,
    required this.onChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
        color: useReasoning ? accentColor.withOpacity(0.1) : Colors.white,
      ),
      child: InkWell(
        onTap: () => onChanged(!useReasoning),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 20,
              color: useReasoning ? accentColor : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              'Razonamiento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: useReasoning ? accentColor : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 32,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: useReasoning ? accentColor : Colors.grey[300],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: useReasoning ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
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

// Nuevo widget simplificado que solo muestra el modelo sin selector
class _ModelDisplay extends StatelessWidget {
  final ModelProfile selected;

  const _ModelDisplay({
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGradientCircle(selected.brand),
          const SizedBox(width: 8),
          Text(
            selected.displayName, // Solo "Gaia", sin subcategoría
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCircle(BrandName b, {double size = 20}) {
    final color = brandColor(b);
    final colors = [
      color,
      Color.lerp(color, Colors.black, 0.2) ?? color,
    ];
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
