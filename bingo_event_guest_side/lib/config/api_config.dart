import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static late String _baseUrl;

  /// Initialize API configuration based on the environment
  static void initialize() {
    if (kIsWeb) {
      // When running on web, use relative URLs or window location
      _detectWebEnvironment();
    } else {
      // For mobile/desktop, use localhost
      _baseUrl = 'http://localhost:5000/api/bingo';
    }
    print('API initialized with base URL: $_baseUrl');
  }

  /// Detects the current web environment and sets API URL accordingly
  static void _detectWebEnvironment() {
    // Check if running locally or on a server
    if (kIsWeb) {
      // Get the current window location
      final String windowLocation = _getWindowLocation();
      
      if (windowLocation.contains('localhost') || windowLocation.contains('127.0.0.1')) {
        // Local development
        _baseUrl = 'http://localhost:5000/api/bingo';
      } else {
        // Server deployment - use relative URL
        // This assumes nginx/IIS proxies /api/* to the backend
        _baseUrl = '/api/bingo';
      }
    } else {
      _baseUrl = '/api/bingo';
    }
  }

  /// Get the current window location (web only)
  static String _getWindowLocation() {
    try {
      // This is a placeholder - in real Flutter web, you'd use:
      // html.window.location.href
      return 'http://localhost:3000';
    } catch (e) {
      return 'http://localhost:3000';
    }
  }

  /// Get the current base URL
  static String get baseUrl => _baseUrl;

  /// Set a custom base URL (useful for testing)
  static void setBaseUrl(String url) {
    _baseUrl = url;
    print('API base URL manually set to: $_baseUrl');
  }
}
