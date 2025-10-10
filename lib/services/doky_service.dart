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
    final pregunta = messages.last.content;

    final payload = {
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': 'tools/call',
      'params': {
        'name': 'llama_doky_consultar_docai',
        'arguments': {
          'pregunta': pregunta,
          'max_tokens': 512,
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

    final data = jsonDecode(resp.body);
    
    if (data['error'] != null) {
      throw Exception('Error de DocAI: ${data['error']['message']}');
    }
    
    final result = data['result'];
    if (result != null && result['content'] != null) {
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

    final controller = StreamController<String>();
    _currentController = controller;

    try {
      final fullResponse = await chatCompletion(
        messages: messages,
        profile: profile,
        systemPromptOverride: systemPromptOverride,
        temperature: temperature,
        useReasoning: useReasoning,
      );

      final words = fullResponse.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (controller.isClosed) break;
        
        String chunk = words[i];
        if (i < words.length - 1) chunk += ' ';
        
        if (!controller.isClosed) controller.add(chunk);
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    } finally {
      if (!controller.isClosed) controller.close();
      _currentController = null;
    }

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
