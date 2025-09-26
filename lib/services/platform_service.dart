import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class PlatformService {
  /// Detecta si el usuario está usando un dispositivo Android en la versión web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) {
      return false;
    }

    try {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      return userAgent.contains('android');
    } catch (e) {
      // En caso de error, asumir que no es Android
      return false;
    }
  }

  /// URL de la app en Google Play Store
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.oriolgds.doky';

  /// Redirecciona al usuario a Google Play Store
  static void redirectToPlayStore() {
    if (kIsWeb) {
      try {
        html.window.location.href = playStoreUrl;
      } catch (e) {
        // En caso de error, intentar abrir en nueva ventana
        html.window.open(playStoreUrl, '_top');
      }
    }
  }
}
