class ModelUnavailableException implements Exception {
  final String message;
  ModelUnavailableException(this.message);

  @override
  String toString() => message;
}

class DataPolicyConfigurationException implements Exception {
  final String message;
  final String configUrl;

  DataPolicyConfigurationException(this.message, this.configUrl);

  @override
  String toString() => message;
}