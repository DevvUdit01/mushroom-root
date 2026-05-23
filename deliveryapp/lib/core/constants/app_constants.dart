class AppConstants {
  static const String baseUrl = 'http://192.168.1.12:5000/api';
  static const String imageBaseUrl = 'http://192.168.1.12:5000/';
  static const String tokenKey = 'delivery_token';

  static String buildImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$imageBaseUrl${path.replaceAll('\\', '/')}';
  }
}
