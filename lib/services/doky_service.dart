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
        'data': [userMessage, history]
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl/call/user_message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final eventId = result['event_id'];
      
      return await _pollResult(eventId);
    } catch (e) {
      debugPrint('Error in DokyService.chatCompletion: $e');
      throw Exception('Error al consultar DocAI: $e');
    }
  }



  Future<String> _pollResult(String eventId) async {
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 1));
      
      final response = await _client.get(
        Uri.parse('$_baseUrl/call/user_message/$eventId'),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = jsonDecode(line.substring(6));
            if (data is List && data.length > 1 && data[1] is List) {
              final chat = data[1] as List;
              if (chat.isNotEmpty && chat.last is List && chat.last.length > 1) {
                return chat.last[1].toString();
              }
            }
          }
        }
      }
    }
    throw Exception('Timeout waiting for response');
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
