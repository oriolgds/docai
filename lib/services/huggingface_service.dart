import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class HuggingFaceService {
  final http.Client _client;
  StreamSubscription? _currentSubscription;
  StreamController<String>? _currentController;

  HuggingFaceService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async {
    print('[DEBUG] HuggingFaceService.chatCompletion: Using modelId = ${profile.modelId}');

    // Construct conversation text from messages
    String conversationText = '';
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.role == ChatRole.user) {
        conversationText += 'User: ${message.content}\n';
      } else if (message.role == ChatRole.assistant) {
        conversationText += 'Assistant: ${message.content}\n';
      }
    }

    // Add the latest user message if not already included
    if (messages.isNotEmpty && !conversationText.contains(messages.last.content)) {
      conversationText += 'User: ${messages.last.content}\n';
    }

    // HuggingFace Gradio API expects specific parameter structure
    final payload = {
      'data': [
        {
          'text': conversationText.trim(),
          'files': [] // Empty files array for text-only chat
        },
        systemPromptOverride ?? 'You are a helpful medical expert. Provide accurate, evidence-based information while being empathetic and understanding.',
        100 // Max new tokens - keeping it reasonable for mobile
      ]
    };

    print('[DEBUG] HuggingFaceService: Payload = ${jsonEncode(payload)}');

    // Construct the correct API endpoint
    String baseUrl = profile.modelId;
    // Remove /gradio_api/call/chat if already present
    if (baseUrl.contains('/gradio_api/call/chat')) {
      baseUrl = baseUrl.split('/gradio_api/call/chat')[0];
    }
    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      baseUrl = 'https://$baseUrl';
    }
    final uri = Uri.parse('$baseUrl/gradio_api/call/chat');
    print('[DEBUG] HuggingFaceService: Calling URL = $uri');
    
    final resp = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print('[DEBUG] HuggingFaceService: Response status = ${resp.statusCode}');
    print('[DEBUG] HuggingFaceService: Response body = ${resp.body}');

    if (resp.statusCode != 200) {
      var message = 'Error de conexión con HuggingFace (${resp.statusCode})';
      
      switch (resp.statusCode) {
        case 403:
          message = 'El modelo de HuggingFace no está disponible públicamente o requiere autenticación especial';
          break;
        case 404:
          message = 'El endpoint del modelo no fue encontrado. Verifica que la URL del modelo sea correcta.';
          break;
        case 429:
          message = 'Demasiadas solicitudes. Inténtalo de nuevo más tarde';
          break;
        case 500:
        case 502:
        case 503:
          message = 'Error interno del servidor de HuggingFace. Inténtalo de nuevo más tarde';
          break;
        default:
          try {
            final data = jsonDecode(resp.body);
            if (data is Map && data['error'] != null) {
              message = data['error'].toString();
            }
          } catch (e) {
            message += ' - ${resp.body}';
          }
      }

      throw Exception(message);
    }

    final data = jsonDecode(resp.body);
    if (data == null || data['event_id'] == null) {
      throw Exception('Invalid response from HuggingFace API: missing event_id');
    }
    
    final eventId = data['event_id'];
    print('[DEBUG] HuggingFaceService: Event ID = $eventId');

    return _pollForResult(profile.modelId, eventId);
  }

  Future<String> _pollForResult(String baseUrl, String eventId) async {
    String url = baseUrl;
    // Remove /gradio_api/call/chat if already present
    if (url.contains('/gradio_api/call/chat')) {
      url = url.split('/gradio_api/call/chat')[0];
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final resultUri = Uri.parse('$url/gradio_api/call/chat/$eventId');
    print('[DEBUG] HuggingFaceService: Polling URL = $resultUri');

    // Poll for result with timeout
    for (int attempt = 0; attempt < 60; attempt++) {
      await Future.delayed(Duration(milliseconds: attempt < 10 ? 500 : 1000));

      try {
        final resp = await _client.get(resultUri);
        print('[DEBUG] HuggingFaceService: Poll attempt $attempt, status = ${resp.statusCode}');
        
        if (resp.statusCode == 200) {
          final lines = resp.body.split('\n');
          
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final jsonStr = line.substring(6).trim();
              
              if (jsonStr == '[DONE]') {
                throw Exception('Stream completed without result');
              }
              
              try {
                final data = jsonDecode(jsonStr);
                print('[DEBUG] HuggingFaceService: Parsed data = $data');
                
                // Handle different response formats
                if (data is List && data.isNotEmpty) {
                  if (data[0] is String && data[0].isNotEmpty) {
                    return data[0];
                  }
                } else if (data is Map) {
                  // Handle error responses
                  if (data['error'] != null) {
                    throw Exception('HuggingFace error: ${data['error']}');
                  }
                  
                  // Handle success responses with different structures
                  if (data['data'] != null && data['data'] is List && data['data'].isNotEmpty) {
                    return data['data'][0].toString();
                  }
                  
                  if (data['result'] != null) {
                    return data['result'].toString();
                  }
                }
              } catch (e) {
                print('[DEBUG] HuggingFaceService: JSON parse error: $e for line: $jsonStr');
                continue;
              }
            }
          }
        } else if (resp.statusCode >= 400) {
          print('[DEBUG] HuggingFaceService: Poll error ${resp.statusCode}: ${resp.body}');
          break;
        }
      } catch (e) {
        print('[DEBUG] HuggingFaceService: Poll attempt $attempt failed: $e');
        if (attempt > 10) {
          // Only break on persistent errors after initial attempts
          break;
        }
      }
    }

    throw Exception('Timeout waiting for HuggingFace response after 60 attempts');
  }

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async* {
    print('[DEBUG] HuggingFaceService.streamChatCompletion: Using modelId = ${profile.modelId}');

    await cancelCurrentStream();

    try {
      // For HuggingFace, we'll simulate streaming by getting the full response
      // and then yielding it word by word for better UX
      final fullResponse = await chatCompletion(
        messages: messages,
        profile: profile,
        systemPromptOverride: systemPromptOverride,
        temperature: temperature,
        useReasoning: useReasoning,
      );

      // Simulate streaming by splitting response into words
      final words = fullResponse.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (_currentController?.isClosed == true) break;
        
        String chunk = words[i];
        if (i < words.length - 1) chunk += ' ';
        
        yield chunk;
        
        // Add small delay for streaming effect
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      print('[DEBUG] HuggingFaceService.streamChatCompletion: Error = $e');
      rethrow;
    }
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

  bool get isStreaming => _currentSubscription != null;

  void dispose() {
    cancelCurrentStream();
    _client.close();
  }
}