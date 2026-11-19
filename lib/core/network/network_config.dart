/// Static network settings. Change [baseUrl] to point at the real backend.
class NetworkConfig {
  const NetworkConfig({
    this.baseUrl = 'https://api.example.com/api/v1',
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
    this.sendTimeout = const Duration(seconds: 20),
    this.enableLogging = true,
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
}
