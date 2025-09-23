import 'dart:async';
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
    bool useReasoning = false,
  }) async {
    final headers = OpenRouterConfig.defaultHeaders();

    final payload = <String, dynamic>{
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

    // Solo agregar el parámetro de razonamiento si está habilitado
    // y usar el formato correcto para la API de OpenRouter/Grok
    if (useReasoning) {
      payload['extra'] = {
        'reasoning': true,
      };
    }

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

  // Stream token-by-token (SSE) from OpenRouter
  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async* {
    final headers = OpenRouterConfig.defaultHeaders();
    final payload = <String, dynamic>{
      'model': profile.modelId,
      'messages': [
        {
          'role': 'system',
          'content': systemPromptOverride ?? OpenRouterConfig.medicalSystemPrompt,
        },
        ...messages.map((m) => m.toOpenRouterMessage()),
      ],
      'temperature': temperature,
      'stream': true,
    };

    // Solo agregar el parámetro de razonamiento si está habilitado
    // y usar el formato correcto para la API de OpenRouter/Grok
    if (useReasoning) {
      payload['extra'] = {
        'reasoning': true,
      };
    }

    final uri = Uri.parse('${OpenRouterConfig.baseUrl}/chat/completions');
    final request = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..body = jsonEncode(payload);
    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      var message = 'OpenRouter error (${streamedResponse.statusCode})';
      try {
        final data = jsonDecode(body);
        if (data is Map && data['error'] != null) {
          message = data['error']['message']?.toString() ?? message;
        }
      } catch (_) {}
      throw Exception(message);
    }

    // Parse SSE events separated by double newlines
    final completer = Completer<void>();
    final controller = StreamController<String>();

    var buffer = '';
    late StreamSubscription sub;
    sub = streamedResponse.stream.transform(utf8.decoder).listen((chunk) {
      buffer += chunk;
      while (true) {
        final idx = buffer.indexOf('\n\n');
        if (idx == -1) break;
        final event = buffer.substring(0, idx);
        buffer = buffer.substring(idx + 2);
        for (final line in event.split('\n')) {
          final l = line.trim();
          if (!l.startsWith('data:')) continue;
          final dataStr = l.substring(5).trim();
          if (dataStr == '[DONE]') {
            controller.close();
            sub.cancel();
            completer.complete();
            return;
          }
          try {
            final json = jsonDecode(dataStr) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            if (choices == null || choices.isEmpty) continue;
            final c0 = choices.first as Map<String, dynamic>;
            final delta = (c0['delta'] ?? c0['message']) as Map<String, dynamic>?;
            final text = delta?['content']?.toString();
            if (text != null && text.isNotEmpty) {
              controller.add(text);
            }
          } catch (_) {
            // ignore malformed chunk
          }
        }
      }
    }, onError: (e) {
      if (!controller.isClosed) controller.addError(e);
      if (!completer.isCompleted) completer.completeError(e);
    }, onDone: () {
      if (!controller.isClosed) controller.close();
      if (!completer.isCompleted) completer.complete();
    });

    yield* controller.stream;
    await completer.future;
  }

  void dispose() => _client.close();
}
