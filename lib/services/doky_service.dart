import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  static const String _baseUrl = 'https://oriolgds-llama-doky.hf.space/gradio_api/call/respond';
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
    final chatHistory = messages.length > 1
        ? messages.sublist(0, messages.length - 1).map((m) => {
            'role': m.role == 'user' ? 'user' : 'assistant',
            'content': m.content,
          }).toList()
        : [];

    final payload = {
      'data': [
        messages.last.content,
        chatHistory,
        128,
        temperature,
        0.9,
      ]
    };

    debugPrint('🚀 POST Request: $_baseUrl');
    debugPrint('📦 Payload: ${jsonEncode(payload)}');

    final postResp = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('📥 POST Response Status: ${postResp.statusCode}');
    debugPrint('📥 POST Response Body: ${postResp.body}');

    if (postResp.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${postResp.statusCode})');
    }

    final eventId = jsonDecode(postResp.body)['event_id'];
    debugPrint('🎫 Event ID: $eventId');
    if (eventId == null) throw Exception('No se recibió event_id');

    await Future.delayed(const Duration(seconds: 2));

    int attempt = 0;
    while (true) {
      attempt++;
      debugPrint('🔄 GET Attempt #$attempt: $_baseUrl/$eventId');
      
      final getResp = await _client.get(Uri.parse('$_baseUrl/$eventId'));
      debugPrint('📥 GET Response Status: ${getResp.statusCode}');
      debugPrint('📥 GET Response Body: ${getResp.body}');
      
      final lines = getResp.body.split('\n');
      
      for (final line in lines.reversed) {
        if (line.startsWith('data: ')) {
          debugPrint('📄 Processing line: $line');
          final data = jsonDecode(line.substring(6));
          debugPrint('📊 Parsed data: $data');
          
          if (data is List && data.isNotEmpty && data[0] is List) {
            final lastMsg = (data[0] as List).last;
            debugPrint('💬 Last message: $lastMsg');
            
            if (lastMsg is List && lastMsg.length > 1) {
              final result = lastMsg[1].toString();
              debugPrint('✅ Result found: $result');
              return result;
            }
          }
        }
      }
      
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    await cancelCurrentStream();

    final chatHistory = messages.length > 1
        ? messages.sublist(0, messages.length - 1).map((m) => {
            'role': m.role == 'user' ? 'user' : 'assistant',
            'content': m.content,
          }).toList()
        : [];

    final payload = {
      'data': [
        messages.last.content,
        chatHistory,
        128,
        temperature,
        0.9,
      ]
    };

    debugPrint('🚀 STREAM POST Request: $_baseUrl');
    debugPrint('📦 STREAM Payload: ${jsonEncode(payload)}');

    final postResp = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('📥 STREAM POST Response Status: ${postResp.statusCode}');
    debugPrint('📥 STREAM POST Response Body: ${postResp.body}');

    if (postResp.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${postResp.statusCode})');
    }

    final eventId = jsonDecode(postResp.body)['event_id'];
    debugPrint('🎫 STREAM Event ID: $eventId');
    if (eventId == null) throw Exception('No se recibió event_id');

    final request = http.Request('GET', Uri.parse('$_baseUrl/$eventId'));
    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${streamedResponse.statusCode})');
    }

    final controller = StreamController<String>();
    _currentController = controller;

    var buffer = '';
    final subscription = streamedResponse.stream.transform(utf8.decoder).listen(
      (chunk) {
        debugPrint('📡 STREAM Chunk received: $chunk');
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i];
          if (!line.startsWith('data: ')) continue;

          try {
            debugPrint('📄 STREAM Processing line: $line');
            final data = jsonDecode(line.substring(6));
            debugPrint('📊 STREAM Parsed data: $data');
            
            if (data is List && data.isNotEmpty && data[0] is List) {
              final lastMsg = (data[0] as List).last;
              debugPrint('💬 STREAM Last message: $lastMsg');
              
              if (lastMsg is List && lastMsg.length > 1 && !controller.isClosed) {
                final result = lastMsg[1].toString();
                debugPrint('✅ STREAM Result: $result');
                controller.add(result);
              }
            }
          } catch (e) {
            debugPrint('❌ STREAM Error parsing: $e');
          }
        }
      },
      onError: (e) {
        debugPrint('❌ STREAM Error: $e');
        if (!controller.isClosed) controller.addError(e);
      },
      onDone: () {
        debugPrint('✅ STREAM Done');
        if (!controller.isClosed) controller.close();
        _currentController = null;
        _currentSubscription = null;
      },
    );

    _currentSubscription = subscription;
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
