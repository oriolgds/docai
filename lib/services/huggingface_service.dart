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
          'text': messages.last.content, // Último mensaje del usuario
          'files': [] // Para archivos multimedia si es necesario
        },
        systemPromptOverride ?? 'You are a helpful medical assistant.',
        100 // Max new tokens
      ]
    };

    final uri = Uri.parse(profile.modelId);
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

    // Parse the response - HuggingFace returns the event ID
    final eventId = resp.body.trim().replaceAll('"', '');
    print('[DEBUG] HuggingFaceService.chatCompletion: Event ID = $eventId');

    // Now poll for the result
    return _pollForResult(profile.modelId, eventId);
  }

  Future<String> _pollForResult(String baseUrl, String eventId) async {
    final resultUri = Uri.parse('$baseUrl/$eventId');

    for (int i = 0; i < 30; i++) { // Poll for up to 30 seconds
      await Future.delayed(const Duration(seconds: 1));

      final resp = await _client.get(resultUri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          final result = data['data'][0];
          if (result is String && result.isNotEmpty) {
            return result;
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
          'files': []
        },
        systemPromptOverride ?? 'You are a helpful medical assistant.',
        100
      ]
    };

    final uri = Uri.parse(profile.modelId);
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

    final eventId = resp.body.trim().replaceAll('"', '');
    print('[DEBUG] HuggingFaceService.streamChatCompletion: Event ID = $eventId');

    // Poll for result and yield chunks
    final controller = StreamController<String>();
    _currentController = controller;

    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }

      try {
        final resultUri = Uri.parse('$uri/$eventId');
        final resultResp = await _client.get(resultUri);

        if (resultResp.statusCode == 200) {
          final data = jsonDecode(resultResp.body);
          if (data['data'] != null && data['data'].isNotEmpty) {
            final result = data['data'][0];
            if (result is String && result.isNotEmpty) {
              if (!controller.isClosed) {
                controller.add(result);
                controller.close();
              }
              timer.cancel();
              _currentController = null;
              return;
            }
          }
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
        }
        timer.cancel();
        _currentController = null;
      }
    });

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