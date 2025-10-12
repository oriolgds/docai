import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:serious_python/serious_python.dart';
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  static const String _spaceId = 'oriolgds/llama-doky';
  
  StreamController<String>? _currentController;
  bool _isDisposed = false;

  DokyService();

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
      
      final pythonCode = '''
from gradio_client import Client

client = Client("$_spaceId")
result = client.predict(
    user_msg="""$userMessage""",
    history=$history,
    api_name="/user_message"
)
print(result[1][-1][1] if result and len(result) > 1 and result[1] else "")
''';

      debugPrint('Executing Python code for Gradio client');
      final result = await SeriousPython.run(pythonCode);
      
      if (result?.isEmpty ?? true) {
        throw Exception('Empty response from Gradio API');
      }
      
      return result!.trim();
    } catch (e) {
      debugPrint('Error in DokyService.chatCompletion: $e');
      throw Exception('Error al consultar DocAI: $e');
    }
  }



  /// Construye el historial de conversación en formato Python
  String _buildHistory(List<ChatMessage> messages) {
    final history = <String>[];
    
    final recentMessages = messages.length > 8 
        ? messages.sublist(messages.length - 8, messages.length - 1)
        : messages.sublist(0, messages.length - 1);
    
    for (int i = 0; i < recentMessages.length; i += 2) {
      if (i + 1 < recentMessages.length) {
        final userMsg = recentMessages[i];
        final assistantMsg = recentMessages[i + 1];
        
        if (userMsg.role == 'user' && assistantMsg.role == 'assistant') {
          final userContent = userMsg.content.replaceAll('"', '\\"');
          final assistantContent = assistantMsg.content.replaceAll('"', '\\"');
          history.add('["$userContent", "$assistantContent"]');
        }
      }
    }
    
    return '[${history.join(", ")}]';
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
  }
}
