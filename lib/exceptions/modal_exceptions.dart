class ModalRateLimitException implements Exception {
  final String message;
  
  ModalRateLimitException([this.message = 'Rate limit exceeded']);
  
  @override
  String toString() => message;
}
