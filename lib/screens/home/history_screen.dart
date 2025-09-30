import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/chat_conversation.dart';
import '../../services/chat_state_manager.dart';
import '../../theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToChat;
  final VoidCallback? onStartNewChat;
  
  const HistoryScreen({
    super.key,
    this.onNavigateToChat,
    this.onStartNewChat,
  });

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
    final l10n = AppLocalizations.of(context)!;
    
    if (!mounted) return;
    
    try {
      await _stateManager.refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  Future<void> _toggleCloudSync(bool enabled, [StateSetter? modalSetState]) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await _stateManager.toggleCloudSync(enabled);
      
      // Actualizar tanto el modal como la pantalla principal
      if (modalSetState != null) {
        modalSetState(() {}); // Actualizar el modal
      }
      
      if (mounted) {
        setState(() {}); // Actualizar la pantalla principal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled 
              ? l10n.cloudSyncEnabled 
              : l10n.cloudSyncDisabled),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  Future<void> _forceSyncNow([StateSetter? modalSetState]) async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!mounted) return;
    
    try {
      await _stateManager.forceSyncNow();
      
      // Actualizar tanto el modal como la pantalla principal
      if (modalSetState != null) {
        modalSetState(() {}); // Actualizar el modal
      }
      
      if (mounted) {
        setState(() {}); // Actualizar la pantalla principal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncCompleted),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncErrorMessage.replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteConversation(ChatConversation conversation) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConversation),
        content: Text('¿Estás seguro de que quieres eliminar "${conversation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteMessage),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _stateManager.deleteConversation(conversation.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.conversationDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e')),
          );
        }
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteHistory),
        content: Text(l10n.deleteHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deletingHistory),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Eliminar todo el historial usando el state manager
      await _stateManager.clearAllHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.historyDeletedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingHistory.replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openConversation(ChatConversation conversation) {
    // Obtener la conversación más actualizada del state manager
    final updatedConversation = _stateManager.getConversationById(conversation.id) ?? conversation;
    
    // Si tenemos callback de navegación, cambiar a la tab de chat
    // Si no, usar navegación tradicional (fallback)
    if (widget.onNavigateToChat != null) {
      // Establecer la conversación en el state manager
      _stateManager.setCurrentConversation(updatedConversation);
      // Cambiar a la tab de chat
      widget.onNavigateToChat!();
    } else {
      // Fallback: navegación tradicional
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            existingConversation: updatedConversation,
          ),
        ),
      );
    }
  }

  void _startNewConversation() {
    // Si tenemos callback de navegación, cambiar a la tab de chat
    // Si no, usar navegación tradicional (fallback)
    if (widget.onStartNewChat != null) {
      // Limpiar la conversación actual para empezar una nueva
      _stateManager.clearCurrentConversation();
      // Cambiar a la tab de chat
      widget.onStartNewChat!();
    } else {
      // Fallback: navegación tradicional
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );
    }
  }

  // Modal para opciones avanzadas
  void _showAdvancedOptionsModal() {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, modalSetState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                l10n.settings,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildSyncSettings(modalSetState),
              
              const SizedBox(height: 20),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _forceRefresh();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.refresh),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _startNewConversation();
                      },
                      icon: const Icon(Icons.chat),
                      label: Text(l10n.newConversation),
                    ),
                  ),
                ],
              ),
              
              if (_stateManager.conversations.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearAllHistory();
                    },
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    label: Text(
                      l10n.clearHistory,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncSettings([StateSetter? modalSetState]) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cloudSyncEnabled = _stateManager.cloudSyncEnabled;
    final isSyncing = _stateManager.isSyncing;
    final lastSyncTime = _stateManager.lastSyncTime;
    final hasError = _stateManager.hasError;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasError 
            ? [Colors.red.shade50, Colors.red.shade100]
            : [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? Colors.red.shade200 : theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasError ? Colors.red.shade100 : theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasError ? Icons.cloud_off : Icons.cloud_outlined, 
                  color: hasError ? Colors.red.shade700 : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sincronización en la nube',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasError ? Colors.red.shade700 : theme.colorScheme.primary,
                  ),
                ),
              ),
              Switch(
                value: cloudSyncEnabled,
                onChanged: (value) => _toggleCloudSync(value, modalSetState),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _getSyncStatusText(cloudSyncEnabled, isSyncing, lastSyncTime, hasError),
                  style: TextStyle(
                    fontSize: 13,
                    color: hasError ? Colors.red.shade600 : theme.colorScheme.primary.withOpacity(0.8),
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
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              if (cloudSyncEnabled && !isSyncing) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: theme.colorScheme.primary),
                  onPressed: () => _forceSyncNow(modalSetState),
                  tooltip: l10n.refresh,
                ),
              ],
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
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
          if (cloudSyncEnabled && !hasError) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.security, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tus datos están protegidos con encriptación',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
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
    final l10n = AppLocalizations.of(context)!;
    
    if (hasError) {
      return l10n.syncError;
    }
    
    if (!cloudSyncEnabled) {
      return l10n.conversationsLocalOnly;
    }
    
    if (isSyncing) {
      return l10n.syncing;
    }
    
    if (lastSyncTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime);
      
      if (difference.inMinutes < 1) {
        return l10n.syncedLessThanMinute;
      } else if (difference.inMinutes < 60) {
        return l10n.syncedMinutesAgo.replaceAll('{minutes}', difference.inMinutes.toString());
      } else if (difference.inHours < 24) {
        return l10n.syncedHoursAgo.replaceAll('{hours}', difference.inHours.toString());
      } else {
        return l10n.syncedDaysAgo.replaceAll('{days}', difference.inDays.toString());
      }
    }
    
    return l10n.autoSyncEnabled;
  }

  Widget _buildCompactConversationCard(ChatConversation conversation) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasUserMessages = conversation.messages.any((m) => m.role.name == 'user');
    final lastUserMessage = hasUserMessages 
        ? conversation.messages.lastWhere((m) => m.role.name == 'user').content
        : l10n.noMessagesYet;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openConversation(conversation),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary.withOpacity(0.7), theme.colorScheme.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Contenido principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        conversation.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      
                      // Último mensaje
                      Text(
                        lastUserMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Info inferior
                      Row(
                        children: [
                          Text(
                            _formatDate(conversation.updatedAt),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conversation.messages.length}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          
                          // Indicador de sincronización
                          Icon(
                            conversation.isCloudSynced
                                ? Icons.cloud_done
                                : Icons.offline_pin,
                            size: 14,
                            color: conversation.isCloudSynced
                                ? theme.colorScheme.primary
                                : Colors.orange.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menú de opciones
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteConversation(conversation);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(l10n.deleteMessage, style: const TextStyle(color: Colors.red, fontSize: 13)),
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noHistoryYet,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startConversation,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startNewConversation,
            icon: const Icon(Icons.chat),
            label: Text(l10n.startConversation),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final conversations = _stateManager.conversations;
    final isLoading = _stateManager.isLoading;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.history,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Botón del modal
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.tune,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: _showAdvancedOptionsModal,
            tooltip: l10n.settings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : conversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _forceRefresh,
                  color: theme.colorScheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return _buildCompactConversationCard(conversations[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        elevation: 4,
        tooltip: l10n.newConversation,
        child: const Icon(Icons.add),
      ),
    );
  }
}