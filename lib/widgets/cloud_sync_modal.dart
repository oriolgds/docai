import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CloudSyncModal extends StatefulWidget {
  const CloudSyncModal({super.key});

  @override
  State<CloudSyncModal> createState() => _CloudSyncModalState();
}

class _CloudSyncModalState extends State<CloudSyncModal>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isSynced = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performSync() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isSynced = true;
    });

    // Close modal after showing success
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isSynced ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Icon(
                      _isSynced ? Icons.cloud_done : Icons.cloud_sync,
                      size: 40,
                      color: _isSynced ? Colors.green : Colors.blue,
                    ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _isSynced
                  ? 'Sincronización Completada'
                  : _isLoading
                      ? 'Sincronizando...'
                      : 'Sincronizar con la Nube',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              _isSynced
                  ? 'Tu historial se ha sincronizado correctamente con la nube. Ahora puedes acceder a él desde cualquier dispositivo.'
                  : _isLoading
                      ? 'Estamos guardando tu historial de forma segura en la nube...'
                      : 'Respalda tu historial de conversaciones en la nube para mantenerlo seguro y accesible desde cualquier dispositivo.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            if (!_isLoading && !_isSynced) ...
              [
                // Sync info cards
                _buildInfoCard(
                  icon: Icons.security,
                  title: 'Seguridad',
                  description: 'Encriptación de extremo a extremo',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.devices,
                  title: 'Multi-dispositivo',
                  description: 'Accede desde cualquier lugar',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.backup,
                  title: 'Respaldo Automático',
                  description: 'Sincronización continua',
                ),
                const SizedBox(height: 32),

                // Sync button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _performSync,
                    icon: const Icon(Icons.cloud_upload, color: Colors.white),
                    label: const Text(
                      'Sincronizar Ahora',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Ahora No',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

            if (_isSynced) ...
              [
                // Success message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Historial sincronizado exitosamente',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CloudSyncModal(),
    );
  }
}