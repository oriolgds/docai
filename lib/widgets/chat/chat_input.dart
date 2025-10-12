import 'package:flutter/material.dart';
import '../../models/model_profile.dart';
import '../../l10n/generated/app_localizations.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onCancel; // New callback for cancel
  final bool isSending;
  final ModelProfile selectedProfile;
  final List<ModelProfile> allProfiles;
  final ValueChanged<ModelProfile> onProfileChanged;
  final VoidCallback onRequestPro;
  final VoidCallback? onScrollToBottom; // New callback for scroll to bottom
  final bool showScrollButton; // New property to control scroll button visibility

  const ChatInput({
    super.key,
    required this.onSend,
    this.onCancel, // Optional cancel callback
    this.isSending = false,
    required this.selectedProfile,
    required this.allProfiles,
    required this.onProfileChanged,
    required this.onRequestPro,
    this.onScrollToBottom, // Optional scroll callback
    this.showScrollButton = false, // Default to hidden
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _scrollButtonAnimController;
  late Animation<double> _scrollButtonAnimation;

  @override
  void initState() {
    super.initState();
    _scrollButtonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollButtonAnimation = CurvedAnimation(
      parent: _scrollButtonAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showScrollButton != oldWidget.showScrollButton) {
      if (widget.showScrollButton) {
        _scrollButtonAnimController.forward();
      } else {
        _scrollButtonAnimController.reverse();
      }
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }
  
  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
  }

  void _scrollToBottom() {
    if (widget.onScrollToBottom != null) {
      widget.onScrollToBottom!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollButtonAnimController.dispose();
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
            // Model selector row
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: _ModelDisplay(
                selected: current,
                allProfiles: widget.allProfiles,
                onChanged: widget.onProfileChanged,
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
                    enabled: !widget.isSending, // Disable when sending
                    minLines: 1,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: widget.isSending 
                          ? AppLocalizations.of(context)!.generatingResponseMessage 
                          : AppLocalizations.of(context)!.typeYourMedicalQuery,
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
                // Scroll to bottom button (animated)
                FadeTransition(
                  opacity: _scrollButtonAnimation,
                  child: SizeTransition(
                    sizeFactor: _scrollButtonAnimation,
                    axis: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4, right: 4),
                      child: IconButton.filled(
                        onPressed: _scrollToBottom,
                        style: IconButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Colors.white,
                        ),
                        tooltip: AppLocalizations.of(context)!.scrollToBottom,
                      ),
                    ),
                  ),
                ),
                // Send/Cancel button
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 4,
                  ), // Align with text field
                  child: IconButton.filled(
                    onPressed: widget.isSending ? _cancel : _submit,
                    style: IconButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: widget.isSending 
                          ? Colors.red.shade600 
                          : null, // Red color when sending/canceling
                    ),
                    icon: widget.isSending
                        ? const Icon(
                            Icons.stop_rounded,
                            size: 20,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                    tooltip: widget.isSending ? AppLocalizations.of(context)!.cancelGeneration : AppLocalizations.of(context)!.send,
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




class _ModelDisplay extends StatefulWidget {
  final ModelProfile selected;
  final List<ModelProfile> allProfiles;
  final ValueChanged<ModelProfile> onChanged;

  const _ModelDisplay({
    required this.selected,
    required this.allProfiles,
    required this.onChanged,
  });

  @override
  State<_ModelDisplay> createState() => _ModelDisplayState();
}

class _ModelDisplayState extends State<_ModelDisplay> {
  bool _isExpanded = false;

  void _showModelSelector() {
    if (widget.allProfiles.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Seleccionar modelo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ...widget.allProfiles.map((profile) =>
              ListTile(
                leading: _buildGradientCircle(profile),
                title: Row(
                  children: [
                    Text(
                      profile.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (profile.provider == ModelProvider.byok) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B894).withOpacity(0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'BYOK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  profile.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (profile.reasoning)
                      Icon(
                        Icons.psychology,
                        size: 20,
                        color: profile.primaryColor,
                      ),
                    if (widget.selected.id == profile.id)
                      Icon(
                        Icons.check_circle,
                        color: profile.primaryColor,
                      ),
                  ],
                ),
                onTap: () {
                  widget.onChanged(profile);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allProfiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
          color: Colors.orange.withOpacity(0.1),
        ),
        child: const Text(
          'No hay modelos disponibles',
          style: TextStyle(color: Colors.orange, fontSize: 14),
        ),
      );
    }

    return GestureDetector(
      onTap: _showModelSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGradientCircle(widget.selected),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.selected.displayName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  if (widget.selected.reasoning) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: widget.selected.primaryColor,
                    ),
                  ],
                  if (widget.selected.provider == ModelProvider.byok) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B894).withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Text(
                        'BYOK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientCircle(ModelProfile profile, {double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [profile.primaryColor, profile.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: profile.primaryColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}