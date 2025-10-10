import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  static const String _mcpUrl = 'https://oriolgds-llama-doky.hf.space/gradio_api/mcp/';
  final http.Client _client;
  StreamSubscription? _currentSubscription;
  StreamController<String>? _currentController;

  DokyService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async {
    final payload = {
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': 'tools/call',
      'params': {
        'name': 'llama_doky_respond',
        'arguments': {
          'message': messages.last.content,
          'chat_history': [],
          'max_tok': 512,
          'temp': temperature,
          'top': 0.9,
        }
      }
    };

    final uri = Uri.parse(_mcpUrl);
    final resp = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${resp.statusCode}): ${resp.body}');
    }

    final lines = resp.body.split('\n');

    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6).trim();
        try {
          final data = jsonDecode(jsonStr);

          if (data['error'] != null) {
            throw Exception('Error de DocAI: ${data['error']['message']}');
          }

          final result = data['result'];
          if (result != null) {
            if (result is String) return result;
            if (result['content'] != null) {
              final content = result['content'];
              if (content is List && content.isNotEmpty) {
                final textContent = content.firstWhere(
                  (item) => item['type'] == 'text',
                  orElse: () => null,
                );
                if (textContent != null && textContent['text'] != null) {
                  return textContent['text'].toString();
                }
              }
            }
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    throw Exception('Respuesta inválida de DocAI');
  }

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    await cancelCurrentStream();

    final payload = {
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': 'tools/call',
      'params': {
        'name': 'llama_doky_respond',
        'arguments': {
          'message': messages.last.content,
          'chat_history': [],
          'max_tok': 512,
          'temp': temperature,
          'top': 0.9,
        },
      },
    };

    final uri = Uri.parse(_mcpUrl);
    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
      })
      ..body = jsonEncode(payload);

    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      throw Exception(
        'Error al consultar DocAI (${streamedResponse.statusCode})',
      );
    }

    final controller = StreamController<String>();
    _currentController = controller;

    var buffer = '';
    final subscription = streamedResponse.stream
        .transform(utf8.decoder)
        .listen(
          (chunk) {
            buffer += chunk;
            final lines = buffer.split('\n');
            buffer = lines.last;

            for (int i = 0; i < lines.length - 1; i++) {
              final line = lines[i];
              if (line.startsWith(':') || line.trim().isEmpty) continue;

              if (line.startsWith('data: ')) {
                final jsonStr = line.substring(6).trim();
                try {
                  final data = jsonDecode(jsonStr);

                  if (data['error'] != null) {
                    if (!controller.isClosed) {
                      controller.addError(
                        Exception(
                          'Error de DocAI: ${data['error']['message']}',
                        ),
                      );
                    }
                    return;
                  }

                  if (data['method'] == 'notifications/progress') {
                    final params = data['params'];
                    if (params != null && params['progress'] != null) {
                      final progressText = params['progress'].toString();
                      if (!controller.isClosed && progressText.isNotEmpty) {
                        controller.add(progressText);
                      }
                    }
                  }

                  final result = data['result'];
                  if (result != null && !controller.isClosed) {
                    if (result is String && result.isNotEmpty) {
                      controller.add(result);
                    } else if (result['content'] != null) {
                      final content = result['content'];
                      if (content is List && content.isNotEmpty) {
                        final textContent = content.firstWhere(
                          (item) => item['type'] == 'text',
                          orElse: () => null,
                        );
                        if (textContent != null &&
                            textContent['text'] != null) {
                          final text = textContent['text'].toString();
                          if (text.isNotEmpty) controller.add(text);
                        }
                      }
                    }
                  }
                } catch (e) {
                  // Skip malformed JSON
                }
              }
            }
          },
          onError: (e) {
            if (!controller.isClosed) controller.addError(e);
          },
          onDone: () {
            if (!controller.isClosed) controller.close();
            _currentController = null;
            _currentSubscription = null;
          },
        );

    _currentSubscription = subscription;
    yield* controller.stream;
  }

  Future<void> cancelCurrentStream() async {
    if (_currentSubscription != null) {
      await _currentSubscription!.cancel();
      _currentSubscription = null;
    }
    if (_currentController != null && !_currentController!.isClosed) {
      await _currentController!.close();
      _currentController = null;
    }
  }

  bool get isStreaming => _currentController != null && !_currentController!.isClosed;

  void dispose() {
    cancelCurrentStream();
    _client.close();
  }
}
