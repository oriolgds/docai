import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/openrouter_config.dart';
import '../models/chat_message.dart';
import '../models/model_profile.dart';
import '../exceptions/model_exceptions.dart';
import 'remote_config_service.dart';
import 'supabase_service.dart';

class OpenRouterService {
  final http.Client _client;
  StreamSubscription? _currentSubscription;
  StreamController<String>? _currentController;

  OpenRouterService({http.Client? client}) : _client = client ?? http.Client();

  /// Get the API key to use for requests (BYOK only - no shared key)
  Future<String> _getApiKey() async {
    try {
      // Get user's BYOK - required
      final userKey = await SupabaseService.getUserApiKey('openrouter');
      if (userKey != null && userKey.isNotEmpty) {
        print('[DEBUG] OpenRouterService: Using user BYOK');
        return userKey;
      }
    } catch (e) {
      print('[DEBUG] OpenRouterService: Error getting user BYOK: $e');
    }

    // No fallback - throw exception if no BYOK
    throw Exception('No API key configured. Please set up your OpenRouter API key in Profile > API Key Settings.');
  }

  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async {
    print('[DEBUG] OpenRouterService.chatCompletion: Using modelId = ${profile.modelId}');
    final apiKey = await _getApiKey();
    final headers = OpenRouterConfig.defaultHeaders(customApiKey: apiKey);

    final payload = <String, dynamic>{
      'model': profile.modelId,
      'messages': [
        {
          'role': 'system',
          'content': systemPromptOverride ?? OpenRouterConfig.medicalSystemPrompt,
        },
        ...messages.map((m) => m.toOpenRouterMessage()),
      ],
      'temperature': temperature,
    };

    // Solo agregar el parámetro de razonamiento si está habilitado
    // usar el formato correcto para la API de OpenRouter (objeto, no boolean)
    if (useReasoning) {
      payload['reasoning'] = {
        'effort': 'high',
      };
    }

    final uri = Uri.parse('${OpenRouterConfig.baseUrl}/chat/completions');
    final resp = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      var message = 'OpenRouter error (${resp.statusCode})';
      print('[DEBUG] OpenRouterService.chatCompletion: HTTP error ${resp.statusCode}, body: ${resp.body}');
      try {
        final data = jsonDecode(resp.body);
        if (data is Map && data['error'] != null) {
          final errorMessage = data['error']['message']?.toString() ?? message;
          print('[DEBUG] OpenRouterService.chatCompletion: API error message: $errorMessage');
          // Detectar errores de modelo no disponible
          if (errorMessage.contains('No endpoints found') ||
              errorMessage.contains('not found') ||
              errorMessage.contains('unavailable')) {
            print('[DEBUG] OpenRouterService.chatCompletion: Model unavailable detected');
            throw ModelUnavailableException('El modelo seleccionado no está disponible temporalmente');
          }
          message = errorMessage;
        }
      } catch (e) {
        if (e is ModelUnavailableException) rethrow;
        print('[DEBUG] OpenRouterService.chatCompletion: Error parsing response: $e');
      }
      throw Exception(message);
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Respuesta vacía del modelo');
    }
    final message = choices.first['message'] as Map<String, dynamic>;
    final content = message['content']?.toString() ?? '';
    if (content.trim().isEmpty) {
      throw Exception('Contenido vacío de la respuesta');
    }
    return content;
  }

  // Stream token-by-token (SSE) from OpenRouter with cancellation support
  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async* {
    print('[DEBUG] OpenRouterService.streamChatCompletion: Using modelId = ${profile.modelId}');
    // Cancel any existing stream
    await cancelCurrentStream();

    final apiKey = await _getApiKey();
    final headers = OpenRouterConfig.defaultHeaders(customApiKey: apiKey);

    final payload = <String, dynamic>{
      'model': profile.modelId,
      'messages': [
        {
          'role': 'system',
          'content': systemPromptOverride ?? OpenRouterConfig.medicalSystemPrompt,
        },
        ...messages.map((m) => m.toOpenRouterMessage()),
      ],
      'temperature': temperature,
      'stream': true,
    };

    // Solo agregar el parámetro de razonamiento si está habilitado
    // usar el formato correcto para la API de OpenRouter (objeto, no boolean)
    if (useReasoning) {
      payload['reasoning'] = {
        'effort': 'high',
      };
    }

    final uri = Uri.parse('${OpenRouterConfig.baseUrl}/chat/completions');
    final request = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..body = jsonEncode(payload);
    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      print('[DEBUG] OpenRouterService.streamChatCompletion: HTTP error ${streamedResponse.statusCode}, body: $body');
      var message = 'OpenRouter error (${streamedResponse.statusCode})';
      try {
        final data = jsonDecode(body);
        if (data is Map && data['error'] != null) {
          final errorMessage = data['error']['message']?.toString() ?? message;
          print('[DEBUG] OpenRouterService.streamChatCompletion: API error message: $errorMessage');
          // Detectar errores de modelo no disponible
          if (errorMessage.contains('No endpoints found') ||
              errorMessage.contains('not found') ||
              errorMessage.contains('unavailable')) {
            print('[DEBUG] OpenRouterService.streamChatCompletion: Model unavailable detected');
            throw ModelUnavailableException('El modelo seleccionado no está disponible temporalmente');
          }
          message = errorMessage;
        }
      } catch (e) {
        if (e is ModelUnavailableException) rethrow;
        print('[DEBUG] OpenRouterService.streamChatCompletion: Error parsing response: $e');
      }
      throw Exception(message);
    }

    // Parse SSE events separated by double newlines
    final completer = Completer<void>();
    final controller = StreamController<String>();
    _currentController = controller;

    var buffer = '';
    late StreamSubscription sub;
    sub = streamedResponse.stream.transform(utf8.decoder).listen((chunk) {
      buffer += chunk;
      while (true) {
        final idx = buffer.indexOf('\n\n');
        if (idx == -1) break;
        final event = buffer.substring(0, idx);
        buffer = buffer.substring(idx + 2);
        for (final line in event.split('\n')) {
          final l = line.trim();
          if (!l.startsWith('data:')) continue;
          final dataStr = l.substring(5).trim();
          if (dataStr == '[DONE]') {
            if (!controller.isClosed) controller.close();
            sub.cancel();
            _currentSubscription = null;
            _currentController = null;
            if (!completer.isCompleted) completer.complete();
            return;
          }
          try {
            final json = jsonDecode(dataStr) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            if (choices == null || choices.isEmpty) continue;
            final c0 = choices.first as Map<String, dynamic>;
            final delta = (c0['delta'] ?? c0['message']) as Map<String, dynamic>?;
            final text = delta?['content']?.toString();
            if (text != null && text.isNotEmpty) {
              if (!controller.isClosed) controller.add(text);
            }
          } catch (_) {
            // ignore malformed chunk
          }
        }
      }
    }, onError: (e) {
      if (!controller.isClosed) controller.addError(e);
      if (!completer.isCompleted) completer.completeError(e);
      _currentSubscription = null;
      _currentController = null;
    }, onDone: () {
      if (!controller.isClosed) controller.close();
      if (!completer.isCompleted) completer.complete();
      _currentSubscription = null;
      _currentController = null;
    });
    
    _currentSubscription = sub;

    yield* controller.stream;
    await completer.future;
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

  // Generar título para una conversación basado en el primer mensaje del usuario
  Future<String> generateConversationTitle(String firstUserMessage) async {
    final models = await RemoteConfigService.getTitleGenerationModels();

    // If no models are configured (disabled), use fallback directly
    if (models.isEmpty) {
      print('[DEBUG] OpenRouterService.generateConversationTitle: Title generation disabled, using fallback');
      return _generateFallbackTitle(firstUserMessage);
    }

    for (final model in models) {
      try {
        print('[DEBUG] OpenRouterService.generateConversationTitle: Trying model $model');
        final title = await _generateTitleWithModel(firstUserMessage, model);
        if (title != null) {
          print('[DEBUG] OpenRouterService.generateConversationTitle: Success with model $model, title: $title');
          return title;
        }
      } catch (e) {
        print('[DEBUG] OpenRouterService.generateConversationTitle: Failed with model $model: $e');
        // Continue to next model
      }
    }

    // Si todos los modelos fallan, usar fallback
    print('[DEBUG] OpenRouterService.generateConversationTitle: All models failed, using fallback');
    return _generateFallbackTitle(firstUserMessage);
  }

  // Generar título usando un modelo específico con timeout
  Future<String?> _generateTitleWithModel(String firstUserMessage, String model) async {
    try {
      final apiKey = await _getApiKey();
      final headers = OpenRouterConfig.defaultHeaders(customApiKey: apiKey);

      final payload = <String, dynamic>{
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': 'Eres un asistente que genera títulos concisos para conversaciones médicas. '
                      'Genera un título de máximo 6 palabras que resuma el tema principal del mensaje del usuario. '
                      'El título debe ser claro, específico y en español. '
                      'No uses comillas ni puntos al final. '
                      'Ejemplos: "Dolor de cabeza persistente", "Consulta sobre diabetes", "Síntomas de gripe".',
          },
          {
            'role': 'user',
            'content': 'Genera un título para esta consulta médica: "$firstUserMessage"',
          },
        ],
        'temperature': 0.3,
        'max_tokens': 20, // Limitar tokens para títulos cortos
      };

      final uri = Uri.parse('${OpenRouterConfig.baseUrl}/chat/completions');

      // Usar timeout de 10 segundos para evitar esperas largas
      final resp = await _client.post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Request timed out after 10 seconds');
      });

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw Exception('No choices in response');
      }

      final message = choices.first['message'] as Map<String, dynamic>;
      final content = message['content']?.toString().trim() ?? '';

      if (content.isEmpty) {
        throw Exception('Empty content in response');
      }

      // Limpiar el título (remover comillas si las hay)
      String title = content;
      if (title.startsWith('"') && title.endsWith('"')) {
        title = title.substring(1, title.length - 1);
      }
      if (title.startsWith("'") && title.endsWith("'")) {
        title = title.substring(1, title.length - 1);
      }

      // Limitar longitud del título
      if (title.length > 50) {
        title = title.substring(0, 47) + '...';
      }

      return title;
    } catch (e) {
      print('[DEBUG] OpenRouterService._generateTitleWithModel: Error with model $model: $e');
      return null; // Return null to indicate failure, allowing fallback to next model
    }
  }

  // Generar título por defecto basado en las primeras palabras del mensaje
  String _generateFallbackTitle(String message) {
    // Limpiar el mensaje
    String cleanMessage = message.trim();
    
    // Tomar las primeras palabras (máximo 6)
    List<String> words = cleanMessage.split(' ');
    if (words.length > 6) {
      words = words.take(6).toList();
      return '${words.join(' ')}...';
    }
    
    // Si es muy corto, usar tal como está
    if (cleanMessage.length <= 50) {
      return cleanMessage;
    }
    
    // Si es muy largo, truncar
    return '${cleanMessage.substring(0, 47)}...';
  }


  void dispose() {
    cancelCurrentStream();
    _client.close();
  }
}