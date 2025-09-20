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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu consulta médica...',
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            _ModelDropdown(
              selected: current,
              allProfiles: widget.allProfiles,
              onChanged: (p) => widget.onProfileChanged(p),
              onRequestPro: widget.onRequestPro,
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: widget.isSending ? null : _submit,
              icon: widget.isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('Enviar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
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
        final entries = <PopupMenuEntry<ModelProfile?>>[];
        BrandName.values.forEach((brand) {
          final profiles = itemsByBrand[brand] ?? [];
          if (profiles.isEmpty) return;
          entries.add(PopupMenuItem<ModelProfile?> (
            enabled: false,
            child: Text(
              _brandHeader(brand),
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black54),
            ),
          ));
          for (final p in profiles) {
            final isHeynos = p.brand == BrandName.heynos;
            entries.add(PopupMenuItem<ModelProfile?>(
              value: isHeynos ? null : p,
              child: Row(
                children: [
                  if (isHeynos)
                    const Icon(Icons.lock_outline, size: 16, color: Colors.black54)
                  else if (p.reasoning)
                    const Icon(Icons.psychology_alt_outlined, size: 16, color: Colors.black54)
                  else
                    const Icon(Icons.bolt, size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text('${_brandShort(brand)} • ${p.tier}'),
                ],
              ),
            ));
          }
          entries.add(const PopupMenuDivider());
        });
        if (entries.isNotEmpty && entries.last is PopupMenuDivider) {
          entries.removeLast();
        }
        return entries;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.model_training, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Text('${_brandShort(selected.brand)} • ${selected.tier}'),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down, size: 18),
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
}
