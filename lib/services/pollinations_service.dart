import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PollinationsService {
  static const String _baseUrl = 'https://text.pollinations.ai';
  static const String _modelsEndpoint = '$_baseUrl/models';

  final http.Client _client;

  PollinationsService({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetch available text models from Pollinations.ai
  Future<List<String>> fetchModels() async {
    try {
      final response = await _client.get(Uri.parse(_modelsEndpoint));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        // The API returns an array of model objects with "name" property
        if (decoded is List) {
          // Extract the "name" field from each model object
          return decoded.map((model) => model['name'] as String).toList();
        } else if (decoded is Map) {
          // Extract model names from object keys (alternative format)
          return decoded.keys.cast<String>().toList();
        } else {
          // Fallback to common models if format is unexpected
          return ['openai', 'mistral', 'llama'];
        }
      } else {
        // Return fallback models on error
        return ['openai', 'mistral', 'llama'];
      }
    } catch (e) {
      // Return fallback models on error instead of throwing
      debugPrint('Error fetching models: $e');
      return ['openai', 'mistral', 'llama'];
    }
  }

  /// Generate chat response (non-streaming) using OpenAI-compatible API
  Future<String> generateText({
    required List<Map<String, dynamic>> messages,
    required String model,
    double temperature = 1.0,
    int maxTokens = 2048,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/openai'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Extract content from OpenAI-compatible response
        if (jsonResponse['choices'] != null &&
            jsonResponse['choices'].isNotEmpty) {
          return jsonResponse['choices'][0]['message']['content'] as String;
        }
        return '';
      } else {
        throw Exception(
          'Request failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error generating text: $e');
    }
  }

  /// Generate 3 follow-up suggestions based on conversation context
  Future<List<String>> generateFollowUpSuggestions({
    required List<Map<String, dynamic>> conversationHistory,
    String language = 'en',
  }) async {
    try {
      // Map language codes to full language names
      final languageNames = {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'ca': 'Catalan',
      };

      final languageName = languageNames[language] ?? 'English';

      final systemPrompt =
          '''Based on the conversation, generate exactly 3 short follow-up questions or topics that the USER could ask or say to continue the conversation.
These should be questions or statements that the USER would TYPE to the chatbot, NOT questions the chatbot would ask the user.
Each suggestion should be concise (max 60 characters) and natural.
Generate the suggestions in $languageName.
Return ONLY the 3 suggestions, one per line, without numbers, bullets, or any other formatting.

Examples of GOOD suggestions (what the user would type):
- "¿Cuáles son los efectos secundarios?"
- "Explícame más sobre este tratamiento"
- "¿Cuánto tiempo dura?"

Examples of BAD suggestions (what the chatbot would ask):
- "¿Quieres saber más?"
- "Dime tu edad"
- "¿Tienes alguna pregunta?"''';

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': 'Generate 3 follow-up suggestions.'},
      ];

      final response = await generateText(
        messages: messages,
        model: 'openai',
        temperature: 1,
        maxTokens: 150,
      );

      // Parse the response into individual suggestions
      final suggestions = response
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .take(3)
          .toList();

      // Ensure we always return 3 suggestions with language-specific defaults
      if (suggestions.length < 3) {
        final defaultSuggestions = {
          'en': [
            'Can you explain more?',
            'What else should I know?',
            'Tell me more about this',
          ],
          'es': [
            '¿Puedes explicar más?',
            '¿Qué más debería saber?',
            'Cuéntame más sobre esto',
          ],
          'fr': [
            'Peux-tu expliquer plus?',
            'Que devrais-je savoir d\'autre?',
            'Dis-m\'en plus',
          ],
          'de': [
            'Kannst du mehr erklären?',
            'Was sollte ich noch wissen?',
            'Erzähl mir mehr',
          ],
          'ca': [
            'Pots explicar més?',
            'Què més hauria de saber?',
            'Explica\'m més sobre això',
          ],
        };

        final fallbacks =
            defaultSuggestions[language] ?? defaultSuggestions['en']!;
        final needed = 3 - suggestions.length;
        return [...suggestions, ...fallbacks.take(needed)];
      }

      return suggestions;
    } catch (e) {
      debugPrint('Error generating follow-up suggestions: $e');
      // Return default suggestions in the requested language
      final defaultSuggestions = {
        'en': [
          'Can you explain more?',
          'What else should I know?',
          'Tell me more about this',
        ],
        'es': [
          '¿Puedes explicar más?',
          '¿Qué más debería saber?',
          'Cuéntame más sobre esto',
        ],
        'fr': [
          'Peux-tu expliquer plus?',
          'Que devrais-je savoir d\'autre?',
          'Dis-m\'en plus',
        ],
        'de': [
          'Kannst du mehr erklären?',
          'Was sollte ich noch wissen?',
          'Erzähl mir mehr',
        ],
        'ca': [
          'Pots explicar més?',
          'Què més hauria de saber?',
          'Explica\'m més sobre això',
        ],
      };
      return defaultSuggestions[language] ?? defaultSuggestions['en']!;
    }
  }

  /// Generate a concise title for the conversation (max 50 characters)
  Future<String> generateConversationTitle({
    required List<Map<String, dynamic>> conversationHistory,
    String language = 'en',
  }) async {
    try {
      // Map language codes to full language names
      final languageNames = {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'ca': 'Catalan',
      };

      final languageName = languageNames[language] ?? 'English';

      final systemPrompt =
          '''Generate a very short, concise title (maximum 50 characters) that summarizes this conversation.
The title should capture the main topic or question.
Generate the title in $languageName.
Return ONLY the title text, without quotes or any formatting.''';

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory.take(4), // Only use first 2 exchanges
        {'role': 'user', 'content': 'Generate a title for this conversation.'},
      ];

      final response = await generateText(
        messages: messages,
        model: 'openai',
        temperature: 1,
        maxTokens: 30,
      );

      final title = response.trim().replaceAll('"', '').replaceAll("'", '');

      // Ensure title doesn't exceed 50 characters
      if (title.length > 50) {
        return '${title.substring(0, 47)}...';
      }

      return title.isNotEmpty ? title : 'Untitled Conversation';
    } catch (e) {
      debugPrint('Error generating conversation title: $e');
      return 'Untitled Conversation';
    }
  }

  void dispose() {
    _client.close();
  }
}
