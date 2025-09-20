import 'package:flutter/material.dart';
import '../../models/model_profile.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isSending;
  final ModelProfile selectedProfile;
  final List<ModelProfile> allProfiles;
  final ValueChanged<ModelProfile> onProfileChanged;
  final VoidCallback onRequestPro;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isSending = false,
    required this.selectedProfile,
    required this.allProfiles,
    required this.onProfileChanged,
    required this.onRequestPro,
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
            // Model selector row
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: _ModelDropdown(
                selected: current,
                allProfiles: widget.allProfiles,
                onChanged: (p) => widget.onProfileChanged(p),
                onRequestPro: widget.onRequestPro,
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

class _ModelDropdown extends StatelessWidget {
  final ModelProfile selected;
  final List<ModelProfile> allProfiles;
  final ValueChanged<ModelProfile> onChanged;
  final VoidCallback onRequestPro;

  const _ModelDropdown({
    required this.selected,
    required this.allProfiles,
    required this.onChanged,
    required this.onRequestPro,
  });

  @override
  Widget build(BuildContext context) {
    final itemsByBrand = <BrandName, List<ModelProfile>>{};
    for (final p in allProfiles) {
      itemsByBrand.putIfAbsent(p.brand, () => []).add(p);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<ModelProfile?>(
          tooltip: 'Cambiar modelo',
          onSelected: (choice) {
            if (choice == null) {
              onRequestPro();
              return;
            }
            onChanged(choice);
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem<ModelProfile?>(
                enabled: false,
                child: Container(
                  width: constraints.maxWidth * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final brand in itemsByBrand.keys) ..._buildBrandSection(brand, itemsByBrand[brand]!)
                    ],
                  ),
                ),
              ),
            ];
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 100,
              maxWidth: 200,
            ),
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
                  _buildGradientCircle(selected.brand),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_brandShort(selected.brand)} • ${selected.tier}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBrandSection(BrandName brand, List<ModelProfile> profiles) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
        child: Text(
          _brandHeader(brand),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
      ),
      ...profiles.map((p) => _buildProfileItem(p)),
      const SizedBox(height: 4),
    ];
  }

  Widget _buildProfileItem(ModelProfile profile) {
    final isHeynos = profile.brand == BrandName.heynos;
    final color = brandColor(profile.brand);
    
    return PopupMenuItem<ModelProfile?>(
      value: isHeynos ? null : profile,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildGradientCircle(profile.brand, size: 24, isLocked: isHeynos),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_brandShort(profile.brand)} • ${profile.tier}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isHeynos ? Colors.grey : null,
                    ),
                  ),
                  if (profile.description.isNotEmpty)
                    Text(
                      profile.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                    ),
                ],
              ),
            ),
            if (isHeynos)
              const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _brandHeader(BrandName b) {
    switch (b) {
      case BrandName.feya:
        return 'Feya (sencillo)';
      case BrandName.gaia:
        return 'Gaia (normal)';
      case BrandName.heynos:
        return 'Heynos (pro)';
    }
  }

  String _brandShort(BrandName b) {
    switch (b) {
      case BrandName.feya:
        return 'Feya';
      case BrandName.gaia:
        return 'Gaia';
      case BrandName.heynos:
        return 'Heynos';
    }
  }

  Widget _buildGradientCircle(BrandName b, {double size = 20, bool isLocked = false}) {
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
          colors: isLocked ? [Colors.grey, Colors.grey.shade700] : colors,
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
      child: isLocked 
          ? Icon(Icons.lock_outline, size: size * 0.6, color: Colors.white)
          : null,
    );
  }

  // Keep this for backward compatibility
  Widget _brandIcon(BrandName b, {bool locked = false}) {
    return _buildGradientCircle(b, isLocked: locked);
  }

  // Tier icon is now part of the profile item design
  Widget _tierIcon(ModelProfile p) => const SizedBox.shrink();

  String _tierAbbr(String tier) {
    switch (tier.toLowerCase()) {
      case 'instant':
        return 'Inst';
      case 'fast':
        return 'Fast';
      case 'balanced':
        return 'Bal';
      case 'reasoning':
        return 'Rsn';
      case 'pro':
        return 'Pro';
      default:
        return tier;
    }
  }
}
