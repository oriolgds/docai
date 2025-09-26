import 'package:flutter/material.dart';
import '../services/platform_service.dart';

class AndroidDownloadModal extends StatelessWidget {
  const AndroidDownloadModal({super.key});

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.oriolgds.doky';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Impide que el usuario cierre el modal
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de Android
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.android, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                '¡Descarga la App Nativa!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                'Para una mejor experiencia en Android, te recomendamos descargar nuestra aplicación nativa desde Google Play Store.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Botón de descarga
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    PlatformService.openUrl(playStoreUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google_play_icon.png',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.shop,
                            size: 24,
                            color: Colors.white,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Descargar desde Play Store',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Texto informativo adicional
              Text(
                'Se abrirá Google Play Store en una nueva pestaña',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget wrapper que muestra el modal automáticamente si es Android en web
class AndroidDownloadWrapper extends StatefulWidget {
  final Widget child;

  const AndroidDownloadWrapper({super.key, required this.child});

  @override
  State<AndroidDownloadWrapper> createState() => _AndroidDownloadWrapperState();
}

class _AndroidDownloadWrapperState extends State<AndroidDownloadWrapper> {
  bool _shouldShowModal = false;

  @override
  void initState() {
    super.initState();
    _checkPlatform();
  }

  void _checkPlatform() {
    // Verificar si es Android en web
    if (PlatformService.isAndroidOnWeb()) {
      // Mostrar el modal después de que el widget se haya construido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _shouldShowModal = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_shouldShowModal)
          Container(
            color: Colors.black54,
            child: const Center(child: AndroidDownloadModal()),
          ),
      ],
    );
  }
}
