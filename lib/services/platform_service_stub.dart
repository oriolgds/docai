import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detecta si estamos en Android desde un navegador web
/// En plataformas nativas, siempre retorna false
bool isAndroidOnWeb() {
  return false;
}

/// Detecta si estamos en un dispositivo móvil desde web
/// En plataformas nativas, siempre retorna false
bool isMobileOnWeb() {
  return false;
}

/// Abre una URL usando url_launcher para plataformas nativas
void openUrl(String url) {
  try {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error opening URL on native platform: $e');
    }
  }
}