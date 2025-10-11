import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_profile.dart';

class DokyService {
  static const String _baseUrl = 'https://oriolgds-llama-doky.hf.space';
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
    final payload = {
      'data': [messages.last.content, 512, temperature, 0.9]
    };

    final headers = {'Content-Type': 'application/json'};
    final token = dotenv.env['HUGGINGFACE_TOKEN'];
    if (token != null && token.isNotEmpty && token != 'your_huggingface_token_here') {
      headers['Authorization'] = 'Bearer $token';
    }

    final postResp = await _client.post(
      Uri.parse('$_baseUrl/call/predict'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (postResp.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${postResp.statusCode})');
    }

    final eventId = jsonDecode(postResp.body)['event_id'];
    if (eventId == null) throw Exception('No se recibió event_id');

    final getResp = await _client.get(Uri.parse('$_baseUrl/call/predict/$eventId'));
    final lines = getResp.body.split('\n');

    for (final line in lines.reversed) {
      if (line.startsWith('data: ')) {
        final data = jsonDecode(line.substring(6));
        if (data is List && data.isNotEmpty) {
          return data[0].toString();
        }
      }
    }

    throw Exception('No se recibió respuesta');
  }

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    await cancelCurrentStream();

    final payload = {
      'data': [messages.last.content, 512, temperature, 0.9]
    };

    final headers = {'Content-Type': 'application/json'};
    final token = dotenv.env['HUGGINGFACE_TOKEN'];
    if (token != null && token.isNotEmpty && token != 'your_huggingface_token_here') {
      headers['Authorization'] = 'Bearer $token';
    }

    final postResp = await _client.post(
      Uri.parse('$_baseUrl/call/predict'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (postResp.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${postResp.statusCode})');
    }

    final eventId = jsonDecode(postResp.body)['event_id'];
    if (eventId == null) throw Exception('No se recibió event_id');

    final request = http.Request('GET', Uri.parse('$_baseUrl/call/predict/$eventId'));
    if (token != null && token.isNotEmpty && token != 'your_huggingface_token_here') {
      request.headers['Authorization'] = 'Bearer $token';
    }
    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${streamedResponse.statusCode})');
    }

    final controller = StreamController<String>();
    _currentController = controller;

    var buffer = '';
    final subscription = streamedResponse.stream.transform(utf8.decoder).listen(
      (chunk) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i];
          if (!line.startsWith('data: ')) continue;

          try {
            final data = jsonDecode(line.substring(6));
            if (data is List && data.isNotEmpty && !controller.isClosed) {
              controller.add(data[0].toString());
            }
          } catch (e) {
            debugPrint('Error parsing SSE: $e');
          }
        }
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
      onDone: () {
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
