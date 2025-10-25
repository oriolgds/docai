import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';
import '../exceptions/modal_exceptions.dart';
import 'supabase_service.dart';

class ModalService {
  StreamController<String>? _currentController;
  bool _isDisposed = false;
  http.Client? _httpClient;

  ModalService();

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

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    if (_isDisposed) throw Exception('ModalService has been disposed');
    
    await cancelCurrentStream();

    final modalUrl = profile.modelId;
    final prompt = _buildPrompt(messages, systemPromptOverride);

    final controller = StreamController<String>();
    _currentController = controller;

    _streamFromModal(
      modalUrl: modalUrl,
      prompt: prompt,
      maxTokens: 5012,
      temperature: temperature,
      controller: controller,
    );

    yield* controller.stream;
  }

  String _buildPrompt(List<ChatMessage> messages, String? systemPromptOverride) {
    final buffer = StringBuffer();
    
    if (systemPromptOverride != null && systemPromptOverride.isNotEmpty) {
      buffer.writeln('System: $systemPromptOverride\n');
    }
    
    for (final msg in messages) {
      if (msg.role == ChatRole.user) {
        buffer.writeln('User: ${msg.content}');
      } else if (msg.role == ChatRole.assistant) {
        buffer.writeln('Assistant: ${msg.content}');
      }
    }
    
    buffer.write('Assistant:');
    return buffer.toString();
  }

  Future<void> _streamFromModal({
    required String modalUrl,
    required String prompt,
    required int maxTokens,
    required double temperature,
    required StreamController<String> controller,
  }) async {
    try {
      _httpClient = http.Client();
      
      debugPrint('[DEBUG] ModalService: Sending to Modal:');
      debugPrint('[DEBUG]   - URL: $modalUrl');
      debugPrint('[DEBUG]   - Prompt length: ${prompt.length}');
      debugPrint('[DEBUG]   - Max tokens: $maxTokens');
      debugPrint('[DEBUG]   - Temperature: $temperature');
      
      final accessToken = SupabaseService.accessToken;
      final userId = SupabaseService.userId;
      
      if (accessToken == null || userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final request = http.Request('POST', Uri.parse(modalUrl))
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['X-User-Id'] = userId
        ..body = jsonEncode({
          'prompt': prompt,
          'max_tokens': maxTokens,
          'temperature': temperature,
          'top_p': 0.9,
        });

      final streamResponse = await _httpClient!.send(request).timeout(
        const Duration(minutes: 15),
        onTimeout: () => throw TimeoutException('La petición tardó demasiado tiempo'),
      );

      if (streamResponse.statusCode == 429) {
        throw ModalRateLimitException();
      }
      
      if (streamResponse.statusCode != 200) {
        throw Exception('Modal API error: ${streamResponse.statusCode}');
      }

      bool hasReceivedTokens = false;
      
      await for (final chunk in streamResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (_isDisposed || controller.isClosed) break;
        
        if (chunk.isEmpty) continue;
        
        // Manejar formato SSE (Server-Sent Events)
        String data = chunk;
        if (chunk.startsWith('data: ')) {
          data = chunk.substring(6).trim();
        }
        
        if (data.isEmpty) continue;
        
        try {
          final parsed = jsonDecode(data);
          
          if (parsed is Map) {
            if (parsed['status'] == 'connected') {
              debugPrint('[DEBUG] ModalService: Connected to stream');
              continue;
            }
            
            if (parsed['status'] == 'completed') {
              debugPrint('[DEBUG] ModalService: Stream completed');
              break;
            }
            
            if (parsed['error'] != null) {
              throw Exception('Modal error: ${parsed['error']}');
            }
            
            if (parsed['token'] != null) {
              final token = parsed['token'] as String;
              hasReceivedTokens = true;
              controller.add(token);
            }
          }
        } catch (e) {
          debugPrint('[DEBUG] ModalService: Error parsing chunk: $e');
        }
      }
      
      if (!controller.isClosed) controller.close();
    } catch (e) {
      debugPrint('[DEBUG] ModalService: Error streaming: $e');
      if (!controller.isClosed) {
        controller.addError(e is ModalRateLimitException ? e : Exception('Error al consultar Modal Labs: $e'));
        controller.close();
      }
    } finally {
      _httpClient?.close();
      _httpClient = null;
      _currentController = null;
    }
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
