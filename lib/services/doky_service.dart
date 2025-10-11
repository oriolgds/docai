import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  // URL de tu Hugging Face Space (actualízala con la correcta)
  static const String _baseUrl = 'https://oriolgds-docai.hf.space';
  final http.Client _client;
  StreamController<String>? _currentController;
  int _requestId = 0;

  DokyService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async {
    try {
      // Construir historial según el formato de tu app.py
      final history = messages.length > 1
          ? messages
              .sublist(0, messages.length - 1)
              .map((m) => [m.content, m.role == 'assistant' ? m.content : ''])
              .toList()
          : [];

      // Paso 1: POST para iniciar predicción
      final startPayload = {
        'data': [
          messages.last.content, // message
          history, // history 
          systemPromptOverride ?? _getDefaultSystemPrompt(), // system_prompt
        ]
      };

      debugPrint('Sending POST to: $_baseUrl/call/predict_api');
      debugPrint('Payload: ${jsonEncode(startPayload)}');

      final startResponse = await _client.post(
        Uri.parse('$_baseUrl/call/predict_api'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(startPayload),
      );

      if (startResponse.statusCode != 200) {
        throw Exception('Error en POST (${startResponse.statusCode}): ${startResponse.body}');
      }

      final startResult = jsonDecode(startResponse.body);
      final eventId = startResult['event_id'];
      
      if (eventId == null) {
        throw Exception('No se recibió event_id: ${startResponse.body}');
      }

      debugPrint('Received event_id: $eventId');

      // Paso 2: GET para obtener resultados
      final resultResponse = await _client.get(
        Uri.parse('$_baseUrl/call/predict_api/$eventId'),
        headers: {
          'Accept': 'text/event-stream',
        },
      );

      if (resultResponse.statusCode != 200) {
        throw Exception('Error en GET (${resultResponse.statusCode}): ${resultResponse.body}');
      }

      // Parsear respuesta de servidor-sent events
      final lines = resultResponse.body.split('\n');
      for (String line in lines) {
        if (line.startsWith('data: ')) {
          try {
            final data = jsonDecode(line.substring(6));
            if (data is List && data.isNotEmpty) {
              return data[0] as String;
            }
          } catch (e) {
            debugPrint('Error parsing line: $line');
            continue;
          }
        }
      }

      throw Exception('No se pudo extraer respuesta válida');

    } catch (e) {
      debugPrint('Error in chatCompletion: $e');
      rethrow;
    }
  }

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    await cancelCurrentStream();

    try {
      final history = messages.length > 1
          ? messages
              .sublist(0, messages.length - 1)
              .map((m) => [m.content, m.role == 'assistant' ? m.content : ''])
              .toList()
          : [];

      // Paso 1: POST para streaming
      final startPayload = {
        'data': [
          messages.last.content,
          history,
          systemPromptOverride ?? _getDefaultSystemPrompt(),
        ],
        'session_hash': 'session_${_requestId++}',
      };

      final startResponse = await _client.post(
        Uri.parse('$_baseUrl/call/generate_response'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(startPayload),
      );

      if (startResponse.statusCode != 200) {
        throw Exception('Error iniciando stream (${startResponse.statusCode}): ${startResponse.body}');
      }

      final startResult = jsonDecode(startResponse.body);
      final eventId = startResult['event_id'];

      if (eventId == null) {
        throw Exception('No event_id para streaming: ${startResponse.body}');
      }

      // Paso 2: GET streaming
      final request = http.Request('GET', Uri.parse('$_baseUrl/call/generate_response/$eventId'));
      request.headers['Accept'] = 'text/event-stream';
      
      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw Exception('Error en stream GET (${streamedResponse.statusCode})');
      }

      final controller = StreamController<String>();
      _currentController = controller;

      var buffer = '';
      
      final subscription = streamedResponse.stream.transform(utf8.decoder).listen(
        (chunk) {
          buffer += chunk;
          final lines = buffer.split('\n');
          buffer = lines.last;

          for (int i = 0; i < lines.length - 1; i++) {
            final line = lines[i].trim();
            if (!line.startsWith('data: ') || line == 'data: ') continue;

            try {
              final jsonData = jsonDecode(line.substring(6));
              
              if (jsonData is List && jsonData.isNotEmpty) {
                final response = jsonData[0] as String;
                if (!controller.isClosed) {
                  controller.add(response);
                }
              }
            } catch (e) {
              debugPrint('Error parsing stream line: $line - $e');
            }
          }
        },
        onError: (e) {
          if (!controller.isClosed) controller.addError(e);
        },
        onDone: () {
          if (!controller.isClosed) controller.close();
          _currentController = null;
        },
      );

      yield* controller.stream;

    } catch (e) {
      debugPrint('Error in streamChatCompletion: $e');
      rethrow;
    }
  }

  String _getDefaultSystemPrompt() {
    return "Eres DocAI, una inteligencia artificial médica avanzada desarrollada por Oriol Giner Díaz. "
        "Tu misión es proporcionar asistencia e información médica de alta calidad, exclusivamente sobre "
        "temas relacionados con la salud.\n\nDirectrices fundamentales:\n"
        "- Proporciona información médica precisa, actualizada y basada en evidencia científica\n"
        "- Mantén un tono profesional, empático y accesible\n"
        "- Usa terminología médica cuando sea necesario, pero explícala en lenguaje sencillo\n"
        "- IMPORTANTE: No sustituyes la consulta con un profesional sanitario\n"
        "- No proporciones diagnósticos definitivos, solo orientación informativa\n"
        "- Para síntomas graves o urgentes, recomienda buscar atención médica inmediata\n"
        "- Si la pregunta no es médica, redirige educadamente al ámbito de la salud";
  }

  Future<void> cancelCurrentStream() async {
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
