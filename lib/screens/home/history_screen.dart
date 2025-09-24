import 'package:flutter/material.dart';
import '../../models/chat_conversation.dart';
import '../../services/chat_history_service.dart';
import '../auth/login_screen.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with WidgetsBindingObserver {
  final ChatHistoryService _historyService = ChatHistoryService();
  List<ChatConversation> _conversations = [];
  bool _isLoading = true;
  bool _cloudSyncEnabled = false;
  bool _isSyncingCloud = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocalConversations(); // Cargar inmediatamente datos locales
    _loadSyncSettings();
    _syncCloudInBackground(); // Sincronizar en segundo plano
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualizar cada vez que se muestra la página
    _loadLocalConversations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar datos locales inmediatamente cuando la app vuelve al foreground
      _loadLocalConversations();
      // Sincronizar en la nube si está habilitado
      _syncCloudInBackground();
    }
  }

  Future<void> _loadLocalConversations() async {
    if (!mounted) return;
    
    // Solo mostrar loading en la primera carga
    if (_conversations.isEmpty) {
      setState(() => _isLoading = true);
    }
    
    try {
      final conversations = await _historyService.getAllConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando conversaciones: $e')),
        );
      }
    }
  }

  Future<void> _syncCloudInBackground() async {
    if (!mounted || !_cloudSyncEnabled || _isSyncingCloud) return;
    
    setState(() => _isSyncingCloud = true);
    
    try {
      // Sincronizar con la nube si está habilitado
      if (_cloudSyncEnabled) {
        await _historyService.forceSyncAllConversations();
        // Recargar conversaciones después de sincronizar
        await _loadLocalConversations();
      }
    } catch (e) {
      // Fallo silencioso para la sincronización en segundo plano
      print('Error sincronizando en segundo plano: $e');
    } finally {
      if (mounted) {
        setState(() => _isSyncingCloud = false);
      }
    }
  }

  Future<void> _forceRefresh() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    // Cargar datos locales primero
    await _loadLocalConversations();
    
    // Luego sincronizar con la nube
    await _syncCloudInBackground();
  }

  Future<void> _loadSyncSettings() async {
    final enabled = await _historyService.isCloudSyncEnabled();
    if (mounted) {
      setState(() => _cloudSyncEnabled = enabled);
    }
  }

  Future<void> _toggleCloudSync(bool enabled) async {
    try {
      await _historyService.setCloudSyncEnabled(enabled);
      setState(() => _cloudSyncEnabled = enabled);
      
      if (enabled) {
        // Forzar sincronización cuando se habilita
        await _historyService.forceSyncAllConversations();
      }
      
      await _forceRefresh(); // Forzar actualización completa tras cambio de sync
      
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
        await _historyService.deleteConversation(conversation.id);
        await _loadLocalConversations(); // Actualización local inmediata tras eliminación
        
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
      
      // Eliminar todo el historial
      await _historyService.clearAllHistory();
      
      // Recargar la lista
      await _loadLocalConversations();
      
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          existingConversation: conversation,
        ),
      ),
    ).then((_) {
      // Actualizar conversaciones cuando se regresa del chat
      _loadLocalConversations(); // Cargar inmediatamente datos locales actualizados
      _syncCloudInBackground(); // Sincronizar en segundo plano si está habilitado
    });
  }

  void _startNewConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    ).then((_) {
      // Actualizar conversaciones cuando se regresa del chat nuevo (CRÍTICO)
      _loadLocalConversations(); // Cargar inmediatamente para mostrar el nuevo chat
      _syncCloudInBackground(); // Sincronizar en segundo plano si está habilitado
    });
  }

  Widget _buildSyncSettings() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Sincronización en la nube',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              const Spacer(),
              Switch(
                value: _cloudSyncEnabled,
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
                  _cloudSyncEnabled
                      ? (_isSyncingCloud ? 'Sincronizando con la nube...' : 'Tus conversaciones se sincronizan automáticamente en la nube')
                      : 'Tus conversaciones se guardan solo en este dispositivo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
              if (_isSyncingCloud) ...[
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
            ],
          ),
          if (_cloudSyncEnabled) ...[
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
          if (_conversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _forceRefresh, // Forzar actualización completa (local + nube)
              tooltip: 'Actualizar',
            ),
          // Botón para eliminar todo el historial
          if (_conversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearAllHistory,
              tooltip: 'Eliminar todo el historial',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSyncSettings(),
                if (_conversations.isEmpty)
                  Expanded(child: _buildEmptyState())
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _forceRefresh, // Pull-to-refresh completo (local + nube)
                      child: ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          return _buildConversationTile(_conversations[index]);
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}