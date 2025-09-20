import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/openrouter_config.dart';
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class OpenRouterService {
  final http.Client _client;
  OpenRouterService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
  }) async {
    final headers = OpenRouterConfig.defaultHeaders();

    final payload = {
      'model': profile.modelId,
      'messages': [
        {
          'role': 'system',
          'content': systemPromptOverride ?? OpenRouterConfig.medicalSystemPrompt,
        },
        ...messages.map((m) => m.toOpenRouterMessage()),
      ],
      'temperature': temperature,
    };

    final uri = Uri.parse('${OpenRouterConfig.baseUrl}/chat/completions');
    final resp = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      var message = 'OpenRouter error (${resp.statusCode})';
      try {
        final data = jsonDecode(resp.body);
        if (data is Map && data['error'] != null) {
          message = data['error']['message']?.toString() ?? message;
        }
      } catch (_) {}
      throw Exception(message);
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Respuesta vacía del modelo');
    }
    final message = choices.first['message'] as Map<String, dynamic>;
    final content = message['content']?.toString() ?? '';
    if (content.trim().isEmpty) {
      throw Exception('Contenido vacío de la respuesta');
    }
    return content;
  }

  void dispose() => _client.close();
}
