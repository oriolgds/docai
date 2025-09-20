import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterConfig {
  static const String baseUrl = 'https://openrouter.ai/api/v1';

  static String get apiKey => (dotenv.env['OPENROUTER_API_KEY'] ?? '').trim();
  static String get siteUrl => (dotenv.env['OPENROUTER_SITE_URL'] ?? 'https://docai.app').trim();

  static Map<String, String> defaultHeaders() {
    final key = apiKey;
    if (key.isEmpty) {
      throw Exception('OpenRouter API key missing. Add OPENROUTER_API_KEY to .env');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $key',
      // Optional but recommended by OpenRouter for rate limits and attribution
      'HTTP-Referer': siteUrl,
      'X-Title': 'DocAI',
    };
  }

  static const String medicalSystemPrompt =
      'Eres un asistente médico que responde preguntas con precisión y empatía. '
      'Proporciona información médica útil y precisa, pero siempre recuerda a los usuarios '
      'que consulten con profesionales de la salud para diagnósticos y tratamientos específicos. '
      'Mantén un tono claro y comprensible, ofrece pautas generales de cuidado, señales de alarma '
      'y recomendaciones de cuándo acudir a urgencias. Si la pregunta sugiere una emergencia potencial, '
      'recomienda buscar atención inmediata. No inventes información y cita guías clínicas reconocidas '
      'cuando sea pertinente.';

  static const String disclaimerText =
      'DocAI no sustituye el consejo médico profesional. La información proporcionada tiene fines '
      'educativos. Para diagnósticos, tratamientos o emergencias acude a un profesional de la salud.';
}
