import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hugging_face_chat_gradio/hf_chat_gradio_client.dart';
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  // URLs para tu Hugging Face Space
  static const String _baseUrl = 'https://oriolgds-llama-doky.hf.space';
  static const String _predictEndpoint = '/call/predict';
  
  late final HuggingFaceChatGradioClient _client;
  StreamController<String>? _currentController;
  bool _isDisposed = false;
  int _requestId = 0;

  DokyService() {
    _client = HuggingFaceChatGradioClient(
      baseUrl: _baseUrl,
      predictEndpoint: _predictEndpoint,
    );
  }

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
      // Construir el mensaje con contexto si es necesario
      String finalMessage = _buildMessageWithContext(
        messages, 
        systemPromptOverride ?? _getDefaultSystemPrompt()
      );

      debugPrint('Sending message to Hugging Face: $finalMessage');

      // Usar el cliente de hugging_face_chat_gradio
      final response = await _client.sendMessage(finalMessage);
      
      debugPrint('Received response from Hugging Face: $response');
      return response;
    } catch (e) {
      debugPrint('Error in DokyService.chatCompletion: $e');
      throw Exception('Error al consultar DocAI: $e');
    }
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
      // Construir el mensaje con contexto
      String finalMessage = _buildMessageWithContext(
        messages, 
        systemPromptOverride ?? _getDefaultSystemPrompt()
      );

      // Create a new stream controller
      final controller = StreamController<String>();
      _currentController = controller;

      // Start the streaming process
      _startStreamingResponse(finalMessage, controller);

      // Yield from the controller's stream
      yield* controller.stream;
    } catch (e) {
      debugPrint('Error in DokyService.streamChatCompletion: $e');
      throw Exception('Error al consultar DocAI: $e');
    }
  }

  /// Construye el mensaje con contexto del historial
  String _buildMessageWithContext(List<ChatMessage> messages, String systemPrompt) {
    if (messages.isEmpty) return '';
    
    final StringBuffer context = StringBuffer();
    
    // Agregar system prompt
    context.writeln('Sistema: $systemPrompt');
    context.writeln();
    
    // Agregar historial de conversación (últimos 5 mensajes para no exceder límites)
    final recentMessages = messages.length > 5 
        ? messages.sublist(messages.length - 5) 
        : messages;
    
    for (int i = 0; i < recentMessages.length - 1; i++) {
      final msg = recentMessages[i];
      final role = msg.role == 'user' ? 'Usuario' : 'DocAI';
      context.writeln('$role: ${msg.content}');
    }
    
    // Agregar mensaje actual
    context.writeln('Usuario: ${messages.last.content}');
    context.writeln('DocAI:');
    
    return context.toString();
  }

  /// Maneja la respuesta de streaming simulando chunks
  Future<void> _startStreamingResponse(
    String message, 
    StreamController<String> controller,
  ) async {
    try {
      // Obtener la respuesta completa usando hugging_face_chat_gradio
      final response = await _client.sendMessage(message);
      
      if (_isDisposed || controller.isClosed) return;

      // Simular streaming dividiendo la respuesta en tokens/palabras
      final words = response.split(' ');
      
      for (int i = 0; i < words.length; i++) {
        if (_isDisposed || controller.isClosed) break;
        
        // Agregar palabra con espaciado apropiado
        final chunk = i == 0 ? words[i] : ' ${words[i]}';
        controller.add(chunk);
        
        // Pequeña pausa para simular streaming real
        await Future.delayed(const Duration(milliseconds: 80));
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

  /// Prompt del sistema por defecto para DocAI
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

/// Implementación alternativa usando huggingface_client para más funcionalidades
/// (Para futuras mejoras cuando se necesiten más características)
class DokyServiceAdvanced {
  static const String _modelId = 'meta-llama/Llama-3.2-3B-Instruct';
  
  // Esta implementación requeriría el paquete huggingface_client
  // Se mantiene como referencia para implementación futura
  
  /*
  late final HuggingFaceClient _client;
  
  DokyServiceAdvanced() {
    final token = dotenv.env['HUGGINGFACE_TOKEN'];
    _client = HuggingFaceClient(
      apiKey: token ?? '',
      baseUrl: 'https://api-inference.huggingface.co',
    );
  }
  
  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async {
    try {
      final response = await _client.textGeneration(
        model: _modelId,
        inputs: messages.last.content,
        parameters: TextGenerationParameters(
          temperature: temperature,
          maxNewTokens: 512,
          topP: 0.9,
          doSample: true,
        ),
      );
      
      return response.generatedText;
    } catch (e) {
      throw Exception('Error al consultar DocAI con HF Client: $e');
    }
  }
  */
}
