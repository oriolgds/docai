import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/chat_conversation.dart';
import '../../services/chat_state_manager.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with WidgetsBindingObserver {
  final ChatStateManager _stateManager = ChatStateManager();
  late final StreamSubscription? _conversationsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Inicializar el state manager
    _stateManager.initialize();
    
    // Escuchar cambios en las conversaciones
    _conversationsSubscription = _stateManager.conversationsStream.listen((_) {
      if (mounted) setState(() {});
    });
    
    // Escuchar cambios generales del state manager
    _stateManager.addListener(_onStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // El state manager se encarga automáticamente de mantener los datos actualizados
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _conversationsSubscription?.cancel();
    _stateManager.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _stateManager.onAppLifecycleStateChanged(state);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _forceRefresh() async {
    if (!mounted) return;
    
    try {
      await _stateManager.refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refrescando: $e')),
        );
      }
    }
  }

  Future<void> _toggleCloudSync(bool enabled) async {
    try {
      await _stateManager.toggleCloudSync(enabled);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled 
              ? 'Sincronización en la nube habilitada' 
              : 'Sincronización en la nube deshabilitada'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _forceSyncNow() async {
    if (!mounted) return;
    
    try {
      await _stateManager.forceSyncNow();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronización completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteConversation(ChatConversation conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar conversación'),
        content: Text('¿Estás seguro de que quieres eliminar "${conversation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _stateManager.deleteConversation(conversation.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversación eliminada')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error eliminando conversación: $e')),
          );
        }
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todo el historial'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todo el historial de chats? '
          'Esta acción no se puede deshacer y eliminará todas las conversaciones '
          'tanto localmente como en la nube.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eliminando historial...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Eliminar todo el historial usando el state manager
      await _stateManager.clearAllHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar historial: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openConversation(ChatConversation conversation) {
    // Obtener la conversación más actualizada del state manager
    final updatedConversation = _stateManager.getConversationById(conversation.id) ?? conversation;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          existingConversation: updatedConversation,
        ),
      ),
    );
    // El state manager se encarga automáticamente de la sincronización
  }

  void _startNewConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
    // El state manager se encarga automáticamente de mantener los datos actualizados
  }

  Widget _buildSyncSettings() {
    final cloudSyncEnabled = _stateManager.cloudSyncEnabled;
    final isSyncing = _stateManager.isSyncing;
    final lastSyncTime = _stateManager.lastSyncTime;
    final hasError = _stateManager.hasError;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasError ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasError ? Colors.red.shade200 : Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasError ? Icons.cloud_off : Icons.cloud_outlined, 
                color: hasError ? Colors.red.shade700 : Colors.blue.shade700
              ),
              const SizedBox(width: 8),
              Text(
                'Sincronización en la nube',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: hasError ? Colors.red.shade700 : Colors.blue.shade700,
                ),
              ),
              const Spacer(),
              Switch(
                value: cloudSyncEnabled,
                onChanged: _toggleCloudSync,
                activeColor: Colors.blue.shade700,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _getSyncStatusText(cloudSyncEnabled, isSyncing, lastSyncTime, hasError),
                  style: TextStyle(
                    fontSize: 13,
                    color: hasError ? Colors.red.shade600 : Colors.blue.shade600,
                  ),
                ),
              ),
              if (isSyncing) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
              if (cloudSyncEnabled && !isSyncing) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: Colors.blue.shade600),
                  onPressed: _forceSyncNow,
                  tooltip: 'Sincronizar ahora',
                ),
              ],
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: 8),
            Text(
              _stateManager.error!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (cloudSyncEnabled && !hasError) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.security, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Tus datos están protegidos con encriptación de extremo a extremo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getSyncStatusText(bool cloudSyncEnabled, bool isSyncing, DateTime? lastSyncTime, bool hasError) {
    if (hasError) {
      return 'Error en la sincronización. Toca refrescar para intentar de nuevo.';
    }
    
    if (!cloudSyncEnabled) {
      return 'Tus conversaciones se guardan solo en este dispositivo';
    }
    
    if (isSyncing) {
      return 'Sincronizando con la nube...';
    }
    
    if (lastSyncTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime);
      
      if (difference.inMinutes < 1) {
        return 'Sincronizado hace menos de un minuto';
      } else if (difference.inMinutes < 60) {
        return 'Última sincronización: hace ${difference.inMinutes} minutos';
      } else if (difference.inHours < 24) {
        return 'Última sincronización: hace ${difference.inHours} horas';
      } else {
        return 'Última sincronización: hace ${difference.inDays} días';
      }
    }
    
    return 'Tus conversaciones se sincronizan automáticamente en la nube';
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    final hasUserMessages = conversation.messages.any((m) => m.role.name == 'user');
    final lastUserMessage = hasUserMessages 
        ? conversation.messages.lastWhere((m) => m.role.name == 'user').content
        : 'Sin mensajes';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.chat_bubble_outline,
            color: Colors.blue.shade700,
            size: 20,
          ),
        ),
        title: Text(
          conversation.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lastUserMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatDate(conversation.updatedAt),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (conversation.isCloudSynced)
                  Icon(
                    Icons.cloud_done,
                    size: 16,
                    color: Colors.blue.shade400,
                  )
                else
                  Icon(
                    Icons.offline_pin,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                const SizedBox(width: 4),
                Text(
                  '${conversation.messages.length} mensajes',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteConversation(conversation);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _openConversation(conversation),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay conversaciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus conversaciones con Docai aparecerán aquí',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
  onPressed: _startNewConversation,
  icon: const Icon(Icons.chat),
  label: const Text('Iniciar nueva conversación'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _stateManager.conversations;
    final isLoading = _stateManager.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          // Botón para nueva conversación
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _startNewConversation,
            tooltip: 'Nueva conversación',
          ),
          if (conversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _forceRefresh,
              tooltip: 'Actualizar',
            ),
          // Botón para eliminar todo el historial
          if (conversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearAllHistory,
              tooltip: 'Eliminar todo el historial',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSyncSettings(),
                if (conversations.isEmpty)
                  Expanded(child: _buildEmptyState())
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _forceRefresh,
                      child: ListView.builder(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          return _buildConversationTile(conversations[index]);
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}