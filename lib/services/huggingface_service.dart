import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class HuggingFaceService {
  final http.Client _client;
  StreamSubscription? _currentSubscription;
  StreamController<String>? _currentController;

  HuggingFaceService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async {
    print('[DEBUG] HuggingFaceService.chatCompletion: Using modelId = ${profile.modelId}');

    final payload = <String, dynamic>{
      'data': [
        {
          'text': messages.last.content,
          'files': [{
            'path': 'https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png',
            'url': 'https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png',
            'orig_name': 'bus.png',
            'size': null,
            'mime_type': 'image/png',
            'is_stream': false,
            'meta': {'_type': 'gradio.FileData'}
          }]
        },
        [],
        systemPromptOverride ?? 'You are a helpful medical expert.',
        2048
      ]
    };

    final uri = Uri.parse('${profile.modelId}/gradio_api/call/chat');
    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      var message = 'Error de conexión con HuggingFace (${resp.statusCode})';
      print('[DEBUG] HuggingFaceService.chatCompletion: HTTP error ${resp.statusCode}, body: ${resp.body}');

      // Manejar códigos de error específicos
      switch (resp.statusCode) {
        case 403:
          message = 'El modelo de HuggingFace no está disponible públicamente o requiere autenticación especial';
          break;
        case 404:
          message = 'El endpoint del modelo no fue encontrado';
          break;
        case 429:
          message = 'Demasiadas solicitudes. Inténtalo de nuevo más tarde';
          break;
        case 500:
        case 502:
        case 503:
          message = 'Error interno del servidor de HuggingFace. Inténtalo de nuevo más tarde';
          break;
        default:
          try {
            final data = jsonDecode(resp.body);
            if (data is Map && data['error'] != null) {
              message = data['error']['message']?.toString() ?? message;
            }
          } catch (e) {
            print('[DEBUG] HuggingFaceService.chatCompletion: Error parsing response: $e');
          }
      }

      throw Exception(message);
    }

    final data = jsonDecode(resp.body);
    final eventId = data['event_id'];
    print('[DEBUG] HuggingFaceService.chatCompletion: Event ID = $eventId');

    return _pollForResult(profile.modelId, eventId);
  }

  Future<String> _pollForResult(String baseUrl, String eventId) async {
    final resultUri = Uri.parse('$baseUrl/gradio_api/call/chat/$eventId');

    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 1));

      final resp = await _client.get(resultUri);
      if (resp.statusCode == 200) {
        final lines = resp.body.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr.trim() != '[DONE]') {
              try {
                final data = jsonDecode(jsonStr);
                if (data is List && data.isNotEmpty && data[0] is String) {
                  return data[0];
                }
              } catch (e) {
                continue;
              }
            }
          }
        }
      }
    }

    throw Exception('Timeout waiting for HuggingFace response');
  }

  // Stream token-by-token from HuggingFace (simplified polling approach)
  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async* {
    print('[DEBUG] HuggingFaceService.streamChatCompletion: Using modelId = ${profile.modelId}');

    // Cancel any existing stream
    await cancelCurrentStream();

    final payload = <String, dynamic>{
      'data': [
        {
          'text': messages.last.content,
          'files': [{
            'path': 'https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png',
            'url': 'https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png',
            'orig_name': 'bus.png',
            'size': null,
            'mime_type': 'image/png',
            'is_stream': false,
            'meta': {'_type': 'gradio.FileData'}
          }]
        },
        [],
        systemPromptOverride ?? 'You are a helpful medical expert.',
        2048
      ]
    };

    final uri = Uri.parse('${profile.modelId}/gradio_api/call/chat');
    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      var message = 'Error de conexión con HuggingFace (${resp.statusCode})';
      print('[DEBUG] HuggingFaceService.streamChatCompletion: HTTP error ${resp.statusCode}, body: ${resp.body}');

      // Manejar códigos de error específicos
      switch (resp.statusCode) {
        case 403:
          message = 'El modelo de HuggingFace no está disponible públicamente o requiere autenticación especial';
          break;
        case 404:
          message = 'El endpoint del modelo no fue encontrado';
          break;
        case 429:
          message = 'Demasiadas solicitudes. Inténtalo de nuevo más tarde';
          break;
        case 500:
        case 502:
        case 503:
          message = 'Error interno del servidor de HuggingFace. Inténtalo de nuevo más tarde';
          break;
        default:
          try {
            final data = jsonDecode(resp.body);
            if (data is Map && data['error'] != null) {
              message = data['error']['message']?.toString() ?? message;
            }
          } catch (e) {
            print('[DEBUG] HuggingFaceService.streamChatCompletion: Error parsing response: $e');
          }
      }

      throw Exception(message);
    }

    final data = jsonDecode(resp.body);
    final eventId = data['event_id'];
    print('[DEBUG] HuggingFaceService.streamChatCompletion: Event ID = $eventId');

    final controller = StreamController<String>();
    _currentController = controller;

    final resultUri = Uri.parse('${profile.modelId}/gradio_api/call/chat/$eventId');
    final request = http.Request('GET', resultUri);
    final streamedResponse = await _client.send(request);

    _currentSubscription = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          if (jsonStr.trim() == '[DONE]') {
            if (!controller.isClosed) controller.close();
            return;
          }
          try {
            final data = jsonDecode(jsonStr);
            if (data is List && data.isNotEmpty && data[0] is String) {
              if (!controller.isClosed) controller.add(data[0]);
            }
          } catch (e) {
            // Ignore parsing errors
          }
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
          controller.close();
        }
      },
      onDone: () {
        if (!controller.isClosed) controller.close();
        _currentSubscription = null;
        _currentController = null;
      },
    );

    yield* controller.stream;
  }

  // Cancel the current streaming request
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

  // Check if there's an active stream
  bool get isStreaming => _currentSubscription != null;

  void dispose() {
    cancelCurrentStream();
    _client.close();
  }
}