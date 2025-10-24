import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TitleGeneratorService {
  static const String _baseUrl = 'https://oriolgds-title-generator.hf.space';
  static const Duration _timeout = Duration(seconds: 30);

  static final TitleGeneratorService _instance = TitleGeneratorService._internal();
  factory TitleGeneratorService() => _instance;
  TitleGeneratorService._internal();

  Future<String> generateTitle(String message) async {
    try {
      debugPrint('[TitleGenerator] Iniciando generación de título para: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      
      // Fase 1: POST para iniciar la petición
      final eventId = await _initiateGeneration(message);
      debugPrint('[TitleGenerator] Event ID obtenido: $eventId');
      
      // Fase 2: GET para obtener el resultado via SSE
      final title = await _fetchResult(eventId);
      debugPrint('[TitleGenerator] Título generado: $title');
      
      return title;
    } catch (e) {
      debugPrint('[TitleGenerator] Error generando título: $e');
      return _generateFallbackTitle(message);
    }
  }

  Future<String> _initiateGeneration(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/call/generate_title'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'data': [message]
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final eventId = data['event_id'] as String?;
        
        if (eventId == null || eventId.isEmpty) {
          throw Exception('No se recibió event_id');
        }
        
        return eventId;
      } else {
        throw Exception('Error en POST: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[TitleGenerator] Error en _initiateGeneration: $e');
      rethrow;
    }
  }

  Future<String> _fetchResult(String eventId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/call/generate_title/$eventId'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseSSEResponse(response.body);
      } else {
        throw Exception('Error en GET: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[TitleGenerator] Error en _fetchResult: $e');
      rethrow;
    }
  }

  String _parseSSEResponse(String sseData) {
    final lines = sseData.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.startsWith('event: complete')) {
        if (i + 1 < lines.length) {
          final dataLine = lines[i + 1].trim();
          if (dataLine.startsWith('data: ')) {
            final jsonData = dataLine.substring(6);
            try {
              final parsed = jsonDecode(jsonData);
              if (parsed is List && parsed.isNotEmpty) {
                return parsed[0].toString().trim();
              }
            } catch (e) {
              debugPrint('[TitleGenerator] Error parseando JSON: $e');
            }
          }
        }
      }
    }
    
    throw Exception('No se encontró evento complete en la respuesta SSE');
  }

  String _generateFallbackTitle(String message) {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) return 'Nueva conversación';
    
    final words = cleanMessage.split(' ');
    if (words.length <= 5) {
      return cleanMessage;
    }
    
    return '${words.take(5).join(' ')}...';
  }
}
