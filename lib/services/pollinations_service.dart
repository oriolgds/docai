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
          'stream': false,
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
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating text: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
