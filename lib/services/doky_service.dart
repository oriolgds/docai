import 'dart:async';
import 'dart:convert';
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
            'metadata': null,
            'content': m.content,
            'options': null,
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

    final postResp = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (postResp.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${postResp.statusCode})');
    }

    final eventId = jsonDecode(postResp.body)['event_id'];
    if (eventId == null) throw Exception('No se recibió event_id');

    final getResp = await _client.get(Uri.parse('$_baseUrl/$eventId'));
    final lines = getResp.body.split('\n');
    
    for (final line in lines.reversed) {
      if (line.startsWith('data: ')) {
        final data = jsonDecode(line.substring(6));
        if (data is List && data.isNotEmpty && data[0] is List) {
          final lastMsg = (data[0] as List).last;
          if (lastMsg is List && lastMsg.length > 1) {
            return lastMsg[1].toString();
          }
        }
      }
    }
    
    throw Exception('Respuesta inválida de DocAI');
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
            'metadata': null,
            'content': m.content,
            'options': null,
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

    final postResp = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (postResp.statusCode != 200) {
      throw Exception('Error al consultar DocAI (${postResp.statusCode})');
    }

    final eventId = jsonDecode(postResp.body)['event_id'];
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
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i];
          if (!line.startsWith('data: ')) continue;

          try {
            final data = jsonDecode(line.substring(6));
            if (data is List && data.isNotEmpty && data[0] is List) {
              final lastMsg = (data[0] as List).last;
              if (lastMsg is List && lastMsg.length > 1 && !controller.isClosed) {
                controller.add(lastMsg[1].toString());
              }
            }
          } catch (e) {
            // Skip malformed JSON
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
