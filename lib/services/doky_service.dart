import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';
import '../models/doky_model_config.dart';
import 'doky_config_service.dart';

class DokyService {
  StreamController<String>? _currentController;
  bool _isDisposed = false;
  http.Client? _httpClient;

  DokyService();

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

  List<List<dynamic>> _buildHistory(List<ChatMessage> messages) {
    final history = <List<dynamic>>[];
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

    final configService = await DokyConfigService.getInstance();
    final modelConfig = configService.getModelById(profile.id) ?? configService.getDefaultModel();
    final gradioUrl = modelConfig.gradioUrl ?? 'https://oriolgds-doky-opus.hf.space';

    final userMessage = messages.isNotEmpty ? messages.last.content : '';
    if (userMessage.isEmpty) throw Exception('No message provided');

    final history = _buildHistory(messages);
    final systemPrompt = systemPromptOverride ?? _getDefaultSystemPrompt();

    final controller = StreamController<String>();
    _currentController = controller;

    _streamFromGradio(
      gradioUrl: gradioUrl,
      message: userMessage,
      history: history,
      systemPrompt: systemPrompt,
      maxTokens: 512,
      temperature: temperature,
      controller: controller,
    );

    yield* controller.stream;
  }

  Future<void> _streamFromGradio({
    required String gradioUrl,
    required String message,
    required List<List<dynamic>> history,
    required String systemPrompt,
    required int maxTokens,
    required double temperature,
    required StreamController<String> controller,
  }) async {
    try {
      _httpClient = http.Client();
      
      final callResponse = await _httpClient!.post(
        Uri.parse('$gradioUrl/call/send_message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': [message, history, systemPrompt, maxTokens, temperature]
        }),
      );

      if (callResponse.statusCode != 200) {
        throw Exception('Failed to initiate call: ${callResponse.statusCode}');
      }

      final eventId = jsonDecode(callResponse.body)['event_id'];
      final streamRequest = http.Request('GET', Uri.parse('$gradioUrl/call/send_message/$eventId'));
      final streamResponse = await _httpClient!.send(streamRequest);

      String lastResponse = '';
      await for (final chunk in streamResponse.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (_isDisposed || controller.isClosed) break;
        
        if (chunk.startsWith('data: ')) {
          final data = chunk.substring(6);
          try {
            final parsed = jsonDecode(data);
            if (parsed is List && parsed.isNotEmpty && parsed[0] is List) {
              final chatHistory = parsed[0] as List;
              if (chatHistory.isNotEmpty) {
                final lastMessage = chatHistory.last;
                if (lastMessage is List && lastMessage.length > 1) {
                  final currentResponse = lastMessage[1] as String? ?? '';
                  if (currentResponse.length > lastResponse.length) {
                    final newChunk = currentResponse.substring(lastResponse.length);
                    controller.add(newChunk);
                    lastResponse = currentResponse;
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('Error parsing chunk: $e');
          }
        }
      }
      
      if (!controller.isClosed) controller.close();
    } catch (e) {
      debugPrint('Error streaming from Gradio: $e');
      if (!controller.isClosed) {
        controller.addError(Exception('Error al consultar DocAI: $e'));
        controller.close();
      }
    } finally {
      _httpClient?.close();
      _httpClient = null;
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
    _httpClient?.close();
    _httpClient = null;
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
