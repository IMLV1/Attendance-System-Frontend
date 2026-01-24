class ApiConfig {
  // Endpoint Backend
  static late String baseUrl;

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 10);

  static const defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static void init() {
    const isProd = bool.fromEnvironment('dart.vm.product');
    baseUrl = isProd
        ? 'http://20.196.155.236:3000'
        : 'http://localhost:8080';
  }
}
