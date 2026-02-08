import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class HordeService {
  static const String _baseUrl = 'https://aihorde.net/api/v2';
  // Use API key from .env or fallback to anonymous
  String get _apiKey => dotenv.env['HORDE_API_KEY'] ?? '0000000000';
  static const String _clientAgent = 'DocAI:1.0:github.com/oriolgds/docai';

  final http.Client _client;

  HordeService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch available text models from Horde AI
  Future<List<String>> fetchModels() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/status/models?type=text'),
        headers: {'apikey': _apiKey, 'Client-Agent': _clientAgent},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Sort by count (usage) descending to get popular models first
        data.sort((a, b) => (b['count'] as num).compareTo(a['count'] as num));
        return data.map((m) => m['name'] as String).toList();
      } else {
        debugPrint(
          'Error fetching models: ${response.statusCode} - ${response.body}',
        );
        return ['koboldcpp/Llama-3-8B-Instruct']; // Fallback
      }
    } catch (e) {
      debugPrint('Error fetching models: $e');
      return ['koboldcpp/Llama-3-8B-Instruct']; // Fallback
    }
  }

  /// Convert chat messages to a prompt string
  String _messagesToPrompt(List<Map<String, dynamic>> messages) {
    final buffer = StringBuffer();

    // Check if there is a system message
    final systemMessage = messages.cast<Map<String, dynamic>>().firstWhere(
      (m) => m['role'] == 'system',
      orElse: () => {},
    );

    if (systemMessage.isNotEmpty) {
      buffer.writeln('System: ${systemMessage['content']}');
      buffer.writeln();
    }

    for (final msg in messages) {
      final role = msg['role'];
      final content = msg['content'];
      if (role == 'system') continue; // Already handled

      // Capitalize role
      final capitalizedRole =
          role.toString().substring(0, 1).toUpperCase() +
          role.toString().substring(1);

      buffer.writeln('$capitalizedRole: $content');
    }

    // Append 'Assistant:' prompt for completion
    if (messages.isNotEmpty && messages.last['role'] != 'assistant') {
      buffer.write('Assistant:');
    }

    return buffer.toString();
  }

  /// Generate text using Horde AI (Async)
  Future<String> generateText({
    required List<Map<String, dynamic>> messages,
    String? model,
    double temperature = 0.7,
    int maxTokens = 1024,
    int maxContextLength = 8192,
  }) async {
    try {
      final prompt = _messagesToPrompt(messages);

      // 1. Initiate generation
      final initiateResponse = await _client.post(
        Uri.parse('$_baseUrl/generate/text/async'),
        headers: {
          'apikey': _apiKey,
          'Client-Agent': _clientAgent,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'prompt': prompt,
          'params': {
            'n': 1,
            'max_context_length': maxContextLength,
            'max_length': maxTokens,
            'temperature': temperature,
            // Generic params that work well for most models
            'rep_pen': 1.1,
            'top_p': 0.9,
          },
          if (model != null) 'models': [model],
        }),
      );

      if (initiateResponse.statusCode != 202) {
        // Try to parse error message
        final body = json.decode(initiateResponse.body);
        throw Exception(
          'Failed to initiate generation: ${body['message'] ?? initiateResponse.body}',
        );
      }

      final initiateData = json.decode(initiateResponse.body);
      final String id = initiateData['id'];

      // 2. Poll for status
      int attempts = 0;
      while (attempts < 60) {
        // Timeout after ~2 minutes (60 * 2s)
        await Future.delayed(const Duration(seconds: 2));
        attempts++;

        final statusResponse = await _client.get(
          Uri.parse('$_baseUrl/generate/text/status/$id'),
          headers: {'apikey': _apiKey, 'Client-Agent': _clientAgent},
        );

        if (statusResponse.statusCode != 200) {
          debugPrint('Error polling status: ${statusResponse.statusCode}');
          continue;
        }

        final statusData = json.decode(statusResponse.body);

        if (statusData['faulted'] == true) {
          throw Exception('Generation faulted');
        }

        if (statusData['done'] == true) {
          final generations = statusData['generations'] as List;
          if (generations.isNotEmpty) {
            return _cleanResponse(generations[0]['text'] as String);
          } else {
            throw Exception('No generations returned');
          }
        }
      }

      throw Exception('Generation timed out');
    } catch (e) {
      debugPrint('Error in generateText: $e');
      rethrow;
    }
  }

  /// Clean response by removing <think>...</think> blocks and unmatched </think> tags
  String _cleanResponse(String text) {
    // 1. Remove <think>...</think> blocks (including newlines)
    text = text.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');

    // 2. Remove anything before a stray </think> (if the start tag was missing/cut off)
    if (text.contains('</think>')) {
      text = text.substring(text.indexOf('</think>') + '</think>'.length);
    }

    return text.trim();
  }

  /// Generate 3 follow-up suggestions
  Future<List<String>> generateFollowUpSuggestions({
    required List<Map<String, dynamic>> conversationHistory,
    String language = 'en',
  }) async {
    try {
      // Similar implementation to PollinationsService but using generateText with prompt engineering
      final languageNames = {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'ca': 'Catalan',
      };
      final languageName = languageNames[language] ?? 'English';

      // We append a specialized prompt to the history
      final promptMessages = List<Map<String, dynamic>>.from(
        conversationHistory,
      );
      promptMessages.add({
        'role': 'system',
        'content':
            '''Generate exactly 3 short follow-up questions options for the USER to ask. 
Target language: $languageName.
Format: Just the 3 questions, one per line. No numbering.
Example:
Question 1?
Question 2?
Question 3?''',
      });

      final response = await generateText(
        messages: promptMessages,
        maxTokens: 100,
        temperature: 0.7,
      );

      final suggestions = response
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .take(3)
          .toList();

      if (suggestions.length < 3) {
        // Fallback logic could be added here if needed, similar to original service
        return [];
      }
      return suggestions;
    } catch (e) {
      debugPrint('Error generating suggestions: $e');
      return [];
    }
  }

  /// Generate conversation title
  Future<String> generateConversationTitle({
    required List<Map<String, dynamic>> conversationHistory,
    String language = 'en',
  }) async {
    try {
      final languageNames = {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'ca': 'Catalan',
      };
      final languageName = languageNames[language] ?? 'English';

      final promptMessages = List<Map<String, dynamic>>.from(
        conversationHistory.take(4),
      );
      promptMessages.add({
        'role': 'system',
        'content':
            'Generate a very short title (max 6 words) for this conversation in $languageName. Return ONLY the title.',
      });

      final response = await generateText(
        messages: promptMessages,
        maxTokens: 30,
        temperature: 0.7,
      );

      return response.trim().replaceAll('"', '').replaceAll("'", '');
    } catch (e) {
      debugPrint('Error generating title: $e');
      return 'Untitled Conversation';
    }
  }

  void dispose() {
    _client.close();
  }
}
