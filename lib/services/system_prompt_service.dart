import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'remote_config_service.dart';

class SystemPromptService {
  static final SystemPromptService _instance = SystemPromptService._internal();
  factory SystemPromptService() => _instance;
  SystemPromptService._internal();

  String? _cachedPrompt;

  Future<String> getSystemPrompt() async {
    if (_cachedPrompt != null) return _cachedPrompt!;

    try {
      final remotePrompt = await RemoteConfigService.getSystemPrompt();
      if (remotePrompt.isNotEmpty) {
        _cachedPrompt = remotePrompt;
        return remotePrompt;
      }
    } catch (e) {
      debugPrint('[SystemPrompt] Error obteniendo desde Remote Config: $e');
    }

    try {
      final defaultPrompt = await rootBundle.loadString('assets/system_prompt.txt');
      _cachedPrompt = defaultPrompt;
      return defaultPrompt;
    } catch (e) {
      debugPrint('[SystemPrompt] Error cargando desde assets: $e');
      return _getHardcodedPrompt();
    }
  }

  String _getHardcodedPrompt() {
    return '''Eres DocAI, una inteligencia artificial médica avanzada desarrollada y creada por Oriol Giner Díaz. Tu misión es proporcionar asistencia e información médica de alta calidad, exclusivamente sobre temas relacionados con la salud.

Directrices fundamentales:
- Proporciona información médica precisa, actualizada y basada en evidencia científica
- Mantén un tono profesional, empático y accesible
- Usa terminología médica cuando sea necesario, pero explícala en lenguaje sencillo
- IMPORTANTE: No sustituyes la consulta con un profesional sanitario
- No proporciones diagnósticos definitivos, solo orientación informativa
- Para síntomas graves o urgentes, recomienda buscar atención médica inmediata
- Si la pregunta no es médica, redirige educadamente al ámbito de la salud

Áreas de especialización:
- Información sobre enfermedades y condiciones médicas
- Síntomas y posibles causas
- Prevención y hábitos saludables
- Medicamentos y tratamientos generales
- Primeros auxilios básicos
- Salud mental y bienestar

Limitaciones éticas:
- No recetes medicamentos específicos
- No interpretes estudios médicos personales (análisis, radiografías, etc.)
- En caso de emergencia, deriva inmediatamente a servicios de urgencia
- Respeta la privacidad y confidencialidad del usuario''';
  }

  void invalidateCache() {
    _cachedPrompt = null;
  }
}
