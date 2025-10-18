import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:serious_python/serious_python.dart';
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  static const String _serverUrl = 'http://127.0.0.1:8765';
  StreamController<String>? _currentController;
  bool _isDisposed = false;
  static bool _pythonInitialized = false;

  DokyService();

  Future<void> _ensurePythonRunning() async {
    if (_pythonInitialized) return;
    
    try {
      await SeriousPython.run("python_app/app.zip", sync: false);
      await Future.delayed(const Duration(seconds: 2));
      _pythonInitialized = true;
    } catch (e) {
      debugPrint('Python initialization error: $e');
      rethrow;
    }
  }

  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async {
    final buffer = StringBuffer();

    await for (final chunk in streamChatCompletion(
      messages: messages,
      profile: profile,
      systemPromptOverride: systemPromptOverride,
      temperature: temperature,
      useReasoning: useReasoning,
    )) {
      buffer.write(chunk);
    }

    return buffer.toString();
  }

  List<List<String>> _buildHistory(List<ChatMessage> messages) {
    final history = <List<String>>[];
    final recentMessages = messages.length > 8 
        ? messages.sublist(messages.length - 8, messages.length - 1)
        : messages.sublist(0, messages.length - 1);
    
    for (int i = 0; i < recentMessages.length; i += 2) {
      if (i + 1 < recentMessages.length) {
        final userMsg = recentMessages[i];
        final assistantMsg = recentMessages[i + 1];
        if (userMsg.role == 'user' && assistantMsg.role == 'assistant') {
          history.add([userMsg.content, assistantMsg.content]);
        }
      }
    }
    return history;
  }

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    if (_isDisposed) throw Exception('DokyService has been disposed');
    
    await cancelCurrentStream();
    await _ensurePythonRunning();

    final controller = StreamController<String>();
    _currentController = controller;

    final userMessage = messages.isNotEmpty ? messages.last.content : '';
    if (userMessage.isEmpty) throw Exception('No message provided');

    final history = _buildHistory(messages);
    final systemPrompt = systemPromptOverride ?? _getDefaultSystemPrompt();

    _streamFromPython(
      message: userMessage,
      history: history,
      systemPrompt: systemPrompt,
      temperature: temperature,
      controller: controller,
    );

    yield* controller.stream;
  }

  Future<void> _streamFromPython({
    required String message,
    required List<List<String>> history,
    required String systemPrompt,
    required double temperature,
    required StreamController<String> controller,
  }) async {
    try {
      final request = http.Request('POST', Uri.parse(_serverUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'message': message,
        'history': history,
        'sys_prompt': systemPrompt,
        'temperature': temperature,
      });

      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        if (_isDisposed || controller.isClosed) break;

        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              controller.close();
              break;
            }
            
            try {
              final json = jsonDecode(data);
              if (json['text'] != null) {
                controller.add(json['text']);
              } else if (json['error'] != null) {
                controller.addError(Exception(json['error']));
              }
            } catch (e) {
              debugPrint('Error parsing SSE: $e');
            }
          }
        }
      }

      client.close();
    } catch (e) {
      debugPrint('Error streaming from Python: $e');
      if (!controller.isClosed) {
        controller.addError(Exception('Error al consultar DocAI: $e'));
        controller.close();
      }
    } finally {
      _currentController = null;
    }
  }

  String _getDefaultSystemPrompt() {
    return '''Eres DocAI, una inteligencia artificial médica avanzada desarrollada por Oriol Giner Díaz. Tu misión es proporcionar asistencia e información médica de alta calidad, exclusivamente sobre temas relacionados con la salud.

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

  Future<void> cancelCurrentStream() async {
    if (_currentController != null && !_currentController!.isClosed) {
      await _currentController!.close();
      _currentController = null;
    }
  }

  bool get isStreaming => _currentController != null && !_currentController!.isClosed;

  void dispose() {
    _isDisposed = true;
    cancelCurrentStream();
  }
}
