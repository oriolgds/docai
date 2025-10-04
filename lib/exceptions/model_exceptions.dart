class ModelUnavailableException implements Exception {
  final String message;
  ModelUnavailableException(this.message);
  
  @override
  String toString() => message;
}