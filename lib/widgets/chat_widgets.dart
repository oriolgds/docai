import 'package:flutter/material.dart';
import 'package:docai/models/medical_preset.dart';
import 'package:docai/models/chat_session.dart';
import 'package:timeago/timeago.dart' as timeago;

// Exported widgets
class PresetSelectorSheet extends StatelessWidget {
  final MedicalPreset selectedPreset;
  final ValueChanged<MedicalPreset> onPresetSelected;

  const PresetSelectorSheet({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3D3441),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Selecciona una especialidad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...MedicalPreset.presets.map((preset) {
            final isSelected = preset.id == selectedPreset.id;

            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(
                milliseconds:
                    200 + (MedicalPreset.presets.indexOf(preset) * 50),
              ),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFFB3BA), Color(0xFFFFDFBA)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF2D2633),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onPresetSelected(preset),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            preset.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  preset.description,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ModelSelectorSheet extends StatelessWidget {
  final List<String> availableModels;
  final String selectedModel;
  final ValueChanged<String> onModelSelected;

  const ModelSelectorSheet({
    super.key,
    required this.availableModels,
    required this.selectedModel,
    required this.onModelSelected,
  });

  static const _modelDisplayNames = {
    'openai': 'OpenAI (GPT-4o-mini)',
    'mistral': 'Mistral Large',
    'llama': 'Llama 3',
    'claude': 'Claude',
    'gemini': 'Gemini',
  };

  static const _modelEmojis = {
    'openai': '🤖',
    'mistral': '⚡',
    'llama': '🦙',
    'claude': '🎭',
    'gemini': '♊',
  };

  String _getModelDisplayName(String model) {
    return _modelDisplayNames[model.toLowerCase()] ?? model.toUpperCase();
  }

  String _getModelEmoji(String model) {
    return _modelEmojis[model.toLowerCase()] ?? '🧠';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3D3441),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Selecciona un modelo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (availableModels.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else
            ...availableModels.map((model) {
              final isSelected = model == selectedModel;

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(
                  milliseconds: 200 + (availableModels.indexOf(model) * 50),
                ),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFFB3BA), Color(0xFFFFDFBA)],
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF2D2633),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onModelSelected(model),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              _getModelEmoji(model),
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _getModelDisplayName(model),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class HistoryDrawer extends StatelessWidget {
  final List<ChatSession> chatHistory;
  final ValueChanged<ChatSession> onSessionSelected;
  final ValueChanged<ChatSession> onDeleteSession;
  final VoidCallback onClearAll;

  const HistoryDrawer({
    super.key,
    required this.chatHistory,
    required this.onSessionSelected,
    required this.onDeleteSession,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF3D3441),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (chatHistory.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ConfirmDeleteAllDialog(onConfirm: onClearAll),
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    label: const Text(
                      'Eliminar todo',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay chats guardados',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final session = chatHistory[index];

                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 200 + (index * 30)),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(30 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Dismissible(
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
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => onDeleteSession(session),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2633),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => onSessionSelected(session),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            MedicalPreset.getById(
                                              session.preset,
                                            ).emoji,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              session.title ?? 'Sin título',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            size: 14,
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${session.messages.length} mensajes',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeago.format(
                                              session.updatedAt,
                                              locale: 'es',
                                            ),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ConfirmNewChatDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmNewChatDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF3D3441),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.chat_bubble_outline, color: Color(0xFFFFB3BA)),
          SizedBox(width: 12),
          Text('Nueva conversación', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: const Text(
        '¿Seguro que quieres iniciar una nueva conversación? Se perderá el historial actual.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB3BA),
          ),
          child: const Text('Sí, nueva chat'),
        ),
      ],
    );
  }
}

class ConfirmPresetChangeDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmPresetChangeDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF3D3441),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.amber),
          SizedBox(width: 12),
          Text('Cambiar especialidad', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: const Text(
        'Para cambiar la especialidad es necesario limpiar el historial actual. ¿Deseas continuar?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: const Text('Sí, cambiar'),
        ),
      ],
    );
  }
}

class ConfirmDeleteAllDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmDeleteAllDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF3D3441),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.delete_forever, color: Colors.red),
          SizedBox(width: 12),
          Text('Eliminar todo', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: const Text(
        '¿Seguro que quieres eliminar todo el historial? Esta acción no se puede deshacer.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar todo'),
        ),
      ],
    );
  }
}
