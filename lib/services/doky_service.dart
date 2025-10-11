import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  // URLs para tu Hugging Face Space
  static const String _baseUrl = 'https://oriolgds-llama-doky.hf.space';
  
  final http.Client _client;
  StreamController<String>? _currentController;
  bool _isDisposed = false;
  int _requestId = 0;

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
      // Intentar con diferentes endpoints en orden de preferencia
      final endpoints = [
        '/call/predict',
        '/call/predict_api', 
        '/api/predict',
        '/gradio_api/call/predict'
      ];
      
      for (String endpoint in endpoints) {
        try {
          final result = await _makeApiCall(messages, endpoint, systemPromptOverride);
          if (result.isNotEmpty) {
            debugPrint('Success with endpoint: $endpoint');
            return result;
          }
        } catch (e) {
          debugPrint('Failed with endpoint $endpoint: $e');
          continue;
        }
      }
      
      throw Exception('Todos los endpoints fallaron');
    } catch (e) {
      debugPrint('Error in DokyService.chatCompletion: $e');
      throw Exception('Error al consultar DocAI: $e');
    }
  }

  /// Realiza la llamada a la API con un endpoint específico
  Future<String> _makeApiCall(
    List<ChatMessage> messages, 
    String endpoint,
    String? systemPromptOverride,
  ) async {
    // Preparar el payload según el formato de tu Space
    final userMessage = messages.isNotEmpty ? messages.last.content : '';
    if (userMessage.isEmpty) throw Exception('No message provided');

    // Construir historial para el contexto
    final history = _buildHistory(messages);
    final systemPrompt = systemPromptOverride ?? _getDefaultSystemPrompt();
    
    // Payload para Gradio API
    final payload = {
      'data': [
        userMessage,      // message
        history,          // history 
        systemPrompt,     // system_prompt
        512,              // max_tokens
        0.7,              // temperature
        0.9,              // top_p
      ],
      'session_hash': 'session_${_requestId++}',
    };

    debugPrint('Making API call to: $_baseUrl$endpoint');
    debugPrint('Payload: ${jsonEncode(payload)}');

    // Paso 1: POST para iniciar predicción
    final postResponse = await _client.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_getHuggingFaceToken() != null) 
          'Authorization': 'Bearer ${_getHuggingFaceToken()}',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));

    if (postResponse.statusCode != 200) {
      throw Exception('POST failed (${postResponse.statusCode}): ${postResponse.body}');
    }

    final postResult = jsonDecode(postResponse.body);
    final eventId = postResult['event_id'];
    
    if (eventId == null) {
      // Si no hay event_id, intentar obtener respuesta directa del POST
      if (postResult['data'] != null && postResult['data'] is List) {
        final data = postResult['data'] as List;
        if (data.isNotEmpty) {
          return data.first.toString();
        }
      }
      throw Exception('No event_id received and no direct data: ${postResponse.body}');
    }

    debugPrint('Received event_id: $eventId');

    // Paso 2: GET para obtener resultados con reintentos
    return await _pollForResults(endpoint, eventId);
  }

  /// Hace polling por los resultados usando el event_id
  Future<String> _pollForResults(String endpoint, String eventId) async {
    const maxRetries = 10;
    const retryDelay = Duration(seconds: 2);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('Polling attempt ${attempt + 1} for event_id: $eventId');
        
        final getResponse = await _client.get(
          Uri.parse('$_baseUrl$endpoint/$eventId'),
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            if (_getHuggingFaceToken() != null) 
              'Authorization': 'Bearer ${_getHuggingFaceToken()}',
          },
        ).timeout(const Duration(seconds: 15));

        if (getResponse.statusCode == 200) {
          final result = _parseServerSentEvents(getResponse.body);
          if (result.isNotEmpty) {
            return result;
          }
        } else if (getResponse.statusCode == 404) {
          debugPrint('Session not found (404), retrying in ${retryDelay.inSeconds}s...');
        } else {
          debugPrint('GET failed (${getResponse.statusCode}): ${getResponse.body}');
        }
        
        // Esperar antes del siguiente intento
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      } catch (e) {
        debugPrint('Polling attempt ${attempt + 1} failed: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      }
    }
    
    throw Exception('Failed to get results after $maxRetries attempts');
  }

  /// Parsea eventos Server-Sent Events
  String _parseServerSentEvents(String responseBody) {
    final lines = responseBody.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('data: ') && line.length > 6) {
        try {
          final jsonData = line.substring(6);
          if (jsonData == 'null' || jsonData.isEmpty) continue;
          
          final data = jsonDecode(jsonData);
          if (data is List && data.isNotEmpty) {
            final result = data[0];
            if (result is String && result.isNotEmpty) {
              return result;
            }
          }
        } catch (e) {
          debugPrint('Error parsing SSE line: $line - $e');
          continue;
        }
      }
    }
    
    return '';
  }

  /// Construye el historial de conversación
  List<List<String>> _buildHistory(List<ChatMessage> messages) {
    final history = <List<String>>[];
    
    // Tomar solo los mensajes anteriores al último (últimos 4 intercambios)
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

  /// Obtiene el token de Hugging Face
  String? _getHuggingFaceToken() {
    final token = dotenv.env['HUGGINGFACE_TOKEN'];
    return (token != null && token.isNotEmpty && token != 'your_huggingface_token_here') 
        ? token : null;
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
        profile: ModelProfile(id: '', name: '', description: ''),
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
    _client.close();
  }
}
