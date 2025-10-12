import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  static const String _baseUrl = 'https://oriolgds-llama-doky.hf.space';
  
  final http.Client _client;
  StreamController<String>? _currentController;
  bool _isDisposed = false;

  DokyService({http.Client? client}) : _client = client ?? http.Client();

  /// Método principal de chat que devuelve la respuesta completa
  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async {
    if (_isDisposed) throw Exception('DokyService has been disposed');
    
    try {
      final userMessage = messages.isNotEmpty ? messages.last.content : '';
      if (userMessage.isEmpty) throw Exception('No message provided');

      final history = _buildHistory(messages);
      
      final payload = {
        'jsonrpc': '2.0',
        'id': DateTime.now().millisecondsSinceEpoch,
        'method': 'tools/call',
        'params': {
          'name': 'llama_doky_chat_streaming_ui',
          'arguments': {
            'message': userMessage,
            'history': history,
          }
        }
      };

      debugPrint('Calling MCP API with payload: ${jsonEncode(payload)}');
      final request = http.Request('POST', Uri.parse('$_baseUrl/gradio_api/mcp/'));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json, text/event-stream';
      request.body = jsonEncode(payload);
      
      final streamedResponse = await _client.send(request);
      
      if (streamedResponse.statusCode != 200) {
        throw Exception('API error: ${streamedResponse.statusCode}');
      }

      String result = '';
      bool isMessageEvent = false;
      
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('event: message')) {
            isMessageEvent = true;
            continue;
          }
          
          if (isMessageEvent && line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty) continue;
            
            try {
              final decodedJson = jsonStr
                  .replaceAll('&quot;', '"')
                  .replaceAll('&#39;', "'");
              
              final data = jsonDecode(decodedJson);
              if (data['result']?['content'] != null) {
                final content = data['result']['content'] as List;
                if (content.isNotEmpty && content[0]['text'] != null) {
                  final text = content[0]['text'] as String;
                  // Extract assistant response from [[user_msg, assistant_msg]] format
                  final match = RegExp(r"\[\['[^']*',\s*'([^']*)']\]").firstMatch(text);
                  if (match != null && match.groupCount >= 1) {
                    result = match.group(1)!.replaceAll('\\n', '\n');
                    break;
                  }
                }
              }
            } catch (e) {
              debugPrint('Error parsing SSE line: $e');
            }
            isMessageEvent = false;
          }
        }
        if (result.isNotEmpty) break;
      }
      
      if (result.isEmpty) throw Exception('No response received');
      return result;
    } catch (e) {
      debugPrint('Error in DokyService.chatCompletion: $e');
      throw Exception('Error al consultar DocAI: $e');
    }
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

  /// Método de streaming que simula respuesta progresiva
  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    if (_isDisposed) throw Exception('DokyService has been disposed');
    
    await cancelCurrentStream();

    try {
      // Create a new stream controller
      final controller = StreamController<String>();
      _currentController = controller;

      // Get the complete response first
      _startStreamingResponse(messages, controller, systemPromptOverride);

      // Yield from the controller's stream
      yield* controller.stream;
    } catch (e) {
      debugPrint('Error in DokyService.streamChatCompletion: $e');
      throw Exception('Error al consultar DocAI: $e');
    }
  }

  /// Maneja la respuesta de streaming simulando chunks
  Future<void> _startStreamingResponse(
    List<ChatMessage> messages,
    StreamController<String> controller,
    String? systemPromptOverride,
  ) async {
    try {
      // Obtener la respuesta completa
      final response = await chatCompletion(
        messages: messages,
        profile: ModelProfile.defaultProfile,
        systemPromptOverride: systemPromptOverride,
      );
      
      if (_isDisposed || controller.isClosed) return;

      // Simular streaming dividiendo la respuesta en palabras
      final words = response.split(' ');
      
      for (int i = 0; i < words.length; i++) {
        if (_isDisposed || controller.isClosed) break;
        
        // Agregar palabra con espaciado apropiado
        final chunk = i == 0 ? words[i] : ' ${words[i]}';
        controller.add(chunk);
        
        // Pequeña pausa para simular streaming real
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
    } catch (e) {
      debugPrint('Error in streaming response: $e');
      if (!controller.isClosed) {
        controller.addError(Exception('Error al procesar respuesta: $e'));
      }
    } finally {
      if (!controller.isClosed) {
        controller.close();
      }
      _currentController = null;
    }
  }



  /// Cancela el stream actual si existe
  Future<void> cancelCurrentStream() async {
    if (_currentController != null && !_currentController!.isClosed) {
      await _currentController!.close();
      _currentController = null;
    }
  }

  /// Verifica si actualmente está transmitiendo
  bool get isStreaming => _currentController != null && !_currentController!.isClosed;

  /// Libera recursos del servicio
  void dispose() {
    _isDisposed = true;
    cancelCurrentStream();
    _client.close();
  }
}
