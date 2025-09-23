import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model_profile.dart';
import '../models/chat_message.dart';
import '../config/openrouter_config.dart';
import 'medical_preferences_service.dart';

class OpenRouterService {
  final http.Client _client = http.Client();
  final MedicalPreferencesService _medicalService = MedicalPreferencesService();

  void dispose() {
    _client.close();
  }

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    bool useReasoning = false,
  }) async* {
    try {
      // Obtener contexto médico personalizado
      String medicalContext = '';
      try {
        medicalContext = await _medicalService.getMedicalContext();
      } catch (e) {
        // Si hay error obteniendo preferencias, usar disclaimer por defecto
        medicalContext = OpenRouterConfig.disclaimerText;
      }

      // Construir mensajes con contexto médico
      final systemMessage = ChatMessage(
        id: 'system-${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.system,
        content: _buildSystemPrompt(medicalContext, useReasoning),
        createdAt: DateTime.now(),
      );
      
      final allMessages = [systemMessage, ...messages];

      final headers = {
        'Authorization': 'Bearer ${OpenRouterConfig.apiKey}',
        'Content-Type': 'application/json',
        'HTTP-Referer': OpenRouterConfig.httpReferer,
        'X-Title': OpenRouterConfig.appName,
      };

      final body = {
        'model': profile.modelId,
        'messages': allMessages
            .map((m) => {
                  'role': m.role.name,
                  'content': m.content,
                })
            .toList(),
        'stream': true,
        'temperature': profile.temperature,
        'top_p': profile.topP,
        'max_tokens': profile.maxTokens,
        // IMPORTANTE: Aquí se activa el reasoning para Grok-4
        if (useReasoning) 'reasoning': true,
      };

      final request = http.Request('POST', Uri.parse(OpenRouterConfig.baseUrl));
      request.headers.addAll(headers);
      request.body = json.encode(body);

      final response = await _client.send(request);

      if (response.statusCode != 200) {
        final error = await response.stream.bytesToString();
        throw Exception('API Error: ${response.statusCode} - $error');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.trim() == '[DONE]') continue;

            try {
              final json = jsonDecode(data);
              final delta = json['choices']?[0]?['delta'];
              if (delta != null && delta['content'] != null) {
                yield delta['content'];
              }
            } catch (e) {
              // Skip malformed JSON chunks
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error en comunicación con OpenRouter: $e');
    }
  }

  String _buildSystemPrompt(String medicalContext, bool useReasoning) {
    String basePrompt = '''Eres DocAI (Gaia), un asistente médico AI especializado en proporcionar información médica educativa y consejos de salud. Tu objetivo es ayudar a los usuarios con sus consultas médicas de manera responsable y precisa.

CONTEXTO MÉDICO DEL USUARIO:
$medicalContext

INSTRUCCIONES IMPORTANTES:
1. SIEMPRE recuerda que DocAI no sustituye el consejo médico profesional
2. La información que proporcionas tiene fines educativos únicamente
3. Para diagnósticos, tratamientos específicos o emergencias, recomienda acudir a un profesional de la salud
4. Ten en cuenta las preferencias médicas del usuario (medicina natural/convencional, alergias, etc.)
5. Personaliza tus respuestas según el contexto médico proporcionado
6. Si hay alergias conocidas, siempre mencionarlas en tratamientos relevantes
7. Respeta las preferencias de tratamiento del usuario
8. Sé empático y comprensivo
9. Proporciona información clara y bien estructurada
10. Si detectas síntomas graves, recomienda atención médica inmediata''';

    if (useReasoning) {
      basePrompt += '''

MODO RAZONAMIENTO ACTIVADO:
- Proporciona un análisis paso a paso de la consulta
- Explica tu proceso de pensamiento médico
- Considera múltiples factores y posibilidades
- Estructura tu respuesta con mayor detalle y fundamentación científica
- Incluye referencias a estudios o guías médicas cuando sea apropiado''';
    }

    return basePrompt;
  }

  Future<String> getChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    bool useReasoning = false,
  }) async {
    final chunks = <String>[];
    await for (final chunk in streamChatCompletion(
      messages: messages,
      profile: profile,
      useReasoning: useReasoning,
    )) {
      chunks.add(chunk);
    }
    return chunks.join();
  }
}
