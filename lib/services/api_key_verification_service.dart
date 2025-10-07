import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Service for validating and verifying API keys for different providers
class ApiKeyVerificationService {
  static const String _functionName = 'verify-api-key';
  static const int _timeoutSeconds = 15;
  
  /// Verifica una API key de OpenRouter usando la Edge Function de Supabase
  static Future<ApiKeyValidationResult> verifyOpenRouterApiKey(String apiKey) async {
    try {
      // Validate format first (quick local check)
      if (!hasValidOpenRouterFormat(apiKey)) {
        return ApiKeyValidationResult.invalid(
          'Formato de clave API inválido. Las claves de OpenRouter deben comenzar con "sk-or-" o "sk-"',
        );
      }

      final client = SupabaseService.client;
      
      // Check authentication
      final session = client.auth.currentSession;
      if (session?.accessToken == null) {
        return ApiKeyValidationResult.error('Usuario no autenticado');
      }

      if (kDebugMode) {
        print('Verifying API key with length: ${apiKey.length}');
      }

      // Call the Supabase Edge Function
      final response = await client.functions.invoke(
        _functionName,
        body: {
          'apiKey': apiKey.trim(),
          'provider': 'openrouter',
        },
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session!.accessToken}',
        },
      ).timeout(
        Duration(seconds: _timeoutSeconds),
        onTimeout: () {
          throw Exception('Timeout: La verificación está tardando demasiado. Por favor, inténtalo de nuevo.');
        },
      );

      if (kDebugMode) {
        print('API verification response status: ${response.status}');
        print('API verification response data: ${response.data}');
      }

      // Handle different response statuses
      if (response.status == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final isValid = data['valid'] == true;
          if (isValid) {
            return ApiKeyValidationResult.valid();
          } else {
            return ApiKeyValidationResult.invalid(
              'La clave API no es válida o no tiene permisos suficientes',
            );
          }
        }
      } else if (response.status == 400) {
        // Bad request - usually invalid input
        final errorData = response.data;
        String errorMessage = 'Solicitud inválida';
        
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['error'] ?? errorMessage;
        }
        
        return ApiKeyValidationResult.invalid(errorMessage);
      } else if (response.status == 429) {
        return ApiKeyValidationResult.error(
          'Límite de solicitudes excedido. Por favor, espera un momento antes de intentar de nuevo.',
        );
      } else if (response.status >= 500) {
        return ApiKeyValidationResult.error(
          'Error del servidor. Por favor, inténtalo de nuevo más tarde.',
        );
      }

      // Fallback for unexpected responses
      return ApiKeyValidationResult.error(
        'Error inesperado durante la verificación (${response.status})',
      );

    } catch (e) {
      if (kDebugMode) {
        print('Error verifying API key: $e');
      }
      
      String errorMessage = 'Error al verificar la clave API';
      
      // Handle specific error types
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('timeout')) {
        errorMessage = 'La verificación tardó demasiado tiempo. Revisa tu conexión e inténtalo de nuevo.';
      } else if (errorString.contains('network') || errorString.contains('socket')) {
        errorMessage = 'Error de conexión. Revisa tu conexión a internet e inténtalo de nuevo.';
      } else if (errorString.contains('unauthorized') || errorString.contains('session')) {
        errorMessage = 'Sesión expirada. Por favor, inicia sesión de nuevo.';
      }
      
      return ApiKeyValidationResult.error(errorMessage);
    }
  }

  /// Verifica si una API key tiene un formato válido para OpenRouter (validación local)
  static bool hasValidOpenRouterFormat(String apiKey) {
    if (apiKey.trim().isEmpty) return false;
    
    final trimmed = apiKey.trim();
    
    // OpenRouter API keys should:
    // 1. Be at least 20 characters long
    // 2. Start with 'sk-or-' or 'sk-'
    return trimmed.length >= 20 && 
           (trimmed.startsWith('sk-or-') || trimmed.startsWith('sk-'));
  }

  /// Sanitiza una API key removiendo espacios y caracteres no válidos
  static String sanitizeApiKey(String apiKey) {
    return apiKey.trim().replaceAll(RegExp(r'\s+'), '');
  }

  /// Obtiene una versión enmascarada de la API key para mostrar en la UI
  static String maskApiKey(String apiKey) {
    if (apiKey.length <= 8) {
      return '*' * apiKey.length;
    }
    
    final start = apiKey.substring(0, 4);
    final end = apiKey.substring(apiKey.length - 4);
    final middle = '*' * (apiKey.length - 8);
    
    return '$start$middle$end';
  }

  /// Valida múltiples aspectos de una API key antes de la verificación remota
  static ApiKeyValidationResult validateApiKeyLocally(String apiKey, String provider) {
    final sanitized = sanitizeApiKey(apiKey);
    
    if (sanitized.isEmpty) {
      return ApiKeyValidationResult.invalid('La clave API no puede estar vacía');
    }
    
    if (provider.toLowerCase() == 'openrouter') {
      if (!hasValidOpenRouterFormat(sanitized)) {
        return ApiKeyValidationResult.invalid(
          'Formato de clave API inválido. Las claves de OpenRouter deben comenzar con "sk-or-" o "sk-" y tener al menos 20 caracteres.',
        );
      }
    }
    
    return ApiKeyValidationResult.validFormat();
  }
}

/// Representa el resultado de la validación de una API key
class ApiKeyValidationResult {
  final bool isValid;
  final bool isError;
  final String? errorMessage;
  final bool isFormatValid;
  
  const ApiKeyValidationResult._(
    this.isValid, 
    this.isError, 
    this.errorMessage, 
    this.isFormatValid,
  );
  
  /// API key is valid and verified
  factory ApiKeyValidationResult.valid() {
    return const ApiKeyValidationResult._(true, false, null, true);
  }
  
  /// API key format is valid but not yet verified remotely
  factory ApiKeyValidationResult.validFormat() {
    return const ApiKeyValidationResult._(false, false, null, true);
  }
  
  /// API key is invalid
  factory ApiKeyValidationResult.invalid(String message) {
    return ApiKeyValidationResult._(false, false, message, false);
  }
  
  /// There was an error during validation (network, server, etc.)
  factory ApiKeyValidationResult.error(String message) {
    return ApiKeyValidationResult._(false, true, message, false);
  }
  
  /// Whether the validation was successful (either valid or format valid)
  bool get isSuccessful => isValid || (isFormatValid && !isError);
  
  /// Get a user-friendly error message
  String get userFriendlyMessage {
    if (isValid) return 'Clave API verificada correctamente';
    if (isError) return errorMessage ?? 'Error durante la verificación';
    if (!isFormatValid) return errorMessage ?? 'Formato de clave API inválido';
    return 'Clave API lista para verificar';
  }
}