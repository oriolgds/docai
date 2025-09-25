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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar conversación'),
        content: Text('¿Estás seguro de que quieres eliminar "${conversation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

  // Modal para opciones avanzadas - Mejorado
  void _showAdvancedOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.settings, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuración',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Gestiona tus conversaciones y sincronización',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSyncSettings(),
                      
                      const SizedBox(height: 24),
                      
                      // Acciones rápidas
                      _buildQuickActions(),
                      
                      const SizedBox(height: 24),
                      
                      // Estadísticas
                      _buildStatistics(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.refresh,
                title: 'Actualizar',
                subtitle: 'Refrescar datos',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _forceRefresh();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Nuevo chat',
                subtitle: 'Iniciar conversación',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _startNewConversation();
                },
              ),
            ),
          ],
        ),
        
        if (_stateManager.conversations.isNotEmpty) ..[
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.delete_sweep,
            title: 'Eliminar historial',
            subtitle: 'Borrar todas las conversaciones',
            color: Colors.red,
            isFullWidth: true,
            onTap: () {
              Navigator.pop(context);
              _clearAllHistory();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: isFullWidth
              ? Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: color,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: color.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final totalConversations = _stateManager.conversations.length;
    final syncedConversations = _stateManager.conversations.where((c) => c.isCloudSynced).length;
    final totalMessages = _stateManager.conversations.fold<int>(
      0, (total, conversation) => total + conversation.messages.length
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.chat,
                value: totalConversations.toString(),
                label: 'Conversaciones',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.cloud_done,
                value: syncedConversations.toString(),
                label: 'Sincronizadas',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.message,
                value: totalMessages.toString(),
                label: 'Mensajes',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSettings() {
    final cloudSyncEnabled = _stateManager.cloudSyncEnabled;
    final isSyncing = _stateManager.isSyncing;
    final lastSyncTime = _stateManager.lastSyncTime;
    final hasError = _stateManager.hasError;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasError 
            ? [Colors.red.shade50, Colors.red.shade100]
            : [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? Colors.red.shade200 : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasError ? Colors.red.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasError ? Icons.cloud_off : Icons.cloud_outlined, 
                  color: hasError ? Colors.red.shade700 : Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sincronización en la nube',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: hasError ? Colors.red.shade700 : Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      _getSyncStatusText(cloudSyncEnabled, isSyncing, lastSyncTime, hasError),
                      style: TextStyle(
                        fontSize: 13,
                        color: hasError ? Colors.red.shade600 : Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: cloudSyncEnabled,
                onChanged: _toggleCloudSync,
                activeColor: Colors.blue.shade700,
              ),
            ],
          ),
          
          if (cloudSyncEnabled && !isSyncing && !hasError) ..[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _forceSyncNow,
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Sincronizar ahora'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          if (isSyncing) ..[
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sincronizando...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          
          if (hasError) ..[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _stateManager.error!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          if (cloudSyncEnabled && !hasError) ..[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, size: 18, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tus datos están protegidos con encriptación end-to-end',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSyncStatusText(bool cloudSyncEnabled, bool isSyncing, DateTime? lastSyncTime, bool hasError) {
    if (hasError) {
      return 'Error en la sincronización';
    }
    
    if (!cloudSyncEnabled) {
      return 'Solo en este dispositivo';
    }
    
    if (isSyncing) {
      return 'Sincronizando datos...';
    }
    
    if (lastSyncTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime);
      
      if (difference.inMinutes < 1) {
        return 'Sincronizado recientemente';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours}h';
      } else {
        return 'Hace ${difference.inDays}d';
      }
    }
    
    return 'Sincronización automática activa';
  }

  Widget _buildCompactConversationCard(ChatConversation conversation) {
    final hasUserMessages = conversation.messages.any((m) => m.role.name == 'user');
    final lastUserMessage = hasUserMessages 
        ? conversation.messages.lastWhere((m) => m.role.name == 'user').content
        : 'Sin mensajes';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openConversation(conversation),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar mejorado
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Contenido principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y fecha en la misma línea
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatDate(conversation.updatedAt),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Último mensaje
                      Text(
                        lastUserMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Info inferior
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${conversation.messages.length} mensajes',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          
                          // Indicador de sincronización mejorado
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: conversation.isCloudSynced
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              conversation.isCloudSynced
                                  ? Icons.cloud_done
                                  : Icons.offline_pin,
                              size: 14,
                              color: conversation.isCloudSynced
                                  ? Colors.green.shade600
                                  : Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menú de opciones mejorado
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteConversation(conversation);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      return '${date.day}/${date.month}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No hay conversaciones',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus conversaciones con Docai\naparecerán aquí',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: _startNewConversation,
            icon: const Icon(Icons.add),
            label: const Text('Nueva conversación'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Historial',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Botón del modal mejorado
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showAdvancedOptionsModal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : conversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _forceRefresh,
                  color: Colors.blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return _buildCompactConversationCard(conversations[index]);
                    },
                  ),
                ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _startNewConversation,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}