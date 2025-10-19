import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/chat_message.dart';
import '../models/model_profile.dart';
import '../models/doky_model_config.dart';
import 'doky_config_service.dart';



// Don't change to MCP or HTTPS because of CORS issues with HF Spaces always use JS client
class DokyService {
  StreamController<String>? _currentController;
  HeadlessInAppWebView? _webView;
  bool _isDisposed = false;
  bool _isInitialized = false;
  String _currentGradioUrl = 'https://oriolgds-doky-opus.hf.space';

  DokyService();

  Future<void> _initWebView(String gradioUrl) async {
    if (_isInitialized && _currentGradioUrl == gradioUrl) return;

    if (_isInitialized && _currentGradioUrl != gradioUrl) {
      await _webView?.dispose();
      _isInitialized = false;
    }

    _currentGradioUrl = gradioUrl;
    final jsCode = await rootBundle.loadString('assets/gradio_client.js');

    _webView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
      ),
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'onChunk',
          callback: (args) {
            debugPrint('Received chunk: ${args[0]}');
            if (_currentController != null && !_currentController!.isClosed) {
              _currentController!.add(args[0].toString());
            }
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'onDone',
          callback: (args) {
            debugPrint('Stream done');
            if (_currentController != null && !_currentController!.isClosed) {
              _currentController!.close();
            }
          },
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('JS Console: ${consoleMessage.message}');
      },
      onLoadStop: (controller, url) async {
        final fullJs = "var GRADIO_URL = '$gradioUrl';\n$jsCode";
        await controller.evaluateJavascript(source: fullJs);
        await Future.delayed(const Duration(milliseconds: 500));
        _isInitialized = true;
      },
    );

    await _webView!.run();
    await _webView!.webViewController?.loadData(data: '<html><body></body></html>');
    await Future.delayed(const Duration(milliseconds: 1500));
  }

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

  Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.7,
    bool useReasoning = false,
  }) async* {
    if (_isDisposed) throw Exception('DokyService has been disposed');
    
    await cancelCurrentStream();

    final configService = await DokyConfigService.getInstance();
    final modelConfig = configService.getModelById(profile.id) ?? configService.getDefaultModel();
    final gradioUrl = modelConfig.gradioUrl ?? 'https://oriolgds-doky-opus.hf.space';

    await _initWebView(gradioUrl);

    final controller = StreamController<String>();
    _currentController = controller;

    final userMessage = messages.isNotEmpty ? messages.last.content : '';
    if (userMessage.isEmpty) throw Exception('No message provided');

    final history = _buildHistory(messages);
    final systemPrompt = systemPromptOverride ?? _getDefaultSystemPrompt();

    _executeJS(
      message: userMessage,
      history: history,
      systemPrompt: systemPrompt,
      temperature: temperature,
      controller: controller,
    );

    yield* controller.stream;
  }

  Future<void> _executeJS({
    required String message,
    required List<List<String>> history,
    required String systemPrompt,
    required double temperature,
    required StreamController<String> controller,
  }) async {
    try {
      final escapedMessage = message.replaceAll("'", "\\'").replaceAll('\n', '\\n');
      final escapedPrompt = systemPrompt.replaceAll("'", "\\'").replaceAll('\n', '\\n');
      final historyJson = jsonEncode(history);

      final jsCall = '''
        streamChat(
          '$escapedMessage',
          $historyJson,
          '$escapedPrompt',
          512,
          $temperature
        ).catch(err => {
          console.error('Error:', err);
          window.flutter_inappwebview.callHandler('onDone');
        });
      ''';

      await _webView?.webViewController?.evaluateJavascript(source: jsCall);
    } catch (e) {
      debugPrint('Error executing JS: $e');
      if (!controller.isClosed) {
        controller.addError(Exception('Error al consultar DocAI: $e'));
        controller.close();
      }
      _currentController = null;
    }
  }

  String _getDefaultSystemPrompt() {
    return '''Eres DocAI, una inteligencia artificial médica avanzada desarrollada por Oriol Giner Díaz. Tu misión es proporcionar asistencia e información médica de alta calidad, exclusivamente sobre temas relacionados con la salud.

Directrices fundamentales:
- Proporciona información médica precisa, actualizada y basada en evidencia científica
- Mantén un tono profesional, empático y accesible
- Usa terminología médica cuando sea necesario, pero explícala en lenguaje sencillo
- IMPORTANTE: No sustituyes la consulta con un profesional sanitario
- No proporciones diagnósticos definitivos, solo orientación informativa
- Para síntomas graves o urgentes, recomienda buscar atención médica inmediata
- Si la pregunta no es médica, redirige educadamente al ámbito de la salud

Áreas de especialización:
- Información sobre enfermedades y condiciones médicas
- Síntomas y posibles causas
- Prevención y hábitos saludables
- Medicamentos y tratamientos generales
- Primeros auxilios básicos
- Salud mental y bienestar

Limitaciones éticas:
- No recetes medicamentos específicos
- No interpretes estudios médicos personales (análisis, radiografías, etc.)
- En caso de emergencia, deriva inmediatamente a servicios de urgencia
- Respeta la privacidad y confidencialidad del usuario''';
  }

  Future<void> cancelCurrentStream() async {
    if (_currentController != null && !_currentController!.isClosed) {
      await _currentController!.close();
      _currentController = null;
    }
  }

  bool get isStreaming => _currentController != null && !_currentController!.isClosed;

  void dispose() {
    _isDisposed = true;
    cancelCurrentStream();
    _webView?.dispose();
  }
}
