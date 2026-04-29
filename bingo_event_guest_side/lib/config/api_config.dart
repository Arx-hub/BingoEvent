import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static late String _rootUrl;

  /// Initialize API configuration based on the environment
  static void initialize() {
    if (kIsWeb) {
      // When running on web, use relative URLs or window location
      _detectWebEnvironment();
    } else {
      // For mobile/desktop, use localhost
      _rootUrl = 'http://localhost:5000/api';
    }
    print('API initialized with root URL: $_rootUrl');
  }

  /// Detects the current web environment and sets API URL accordingly
  static void _detectWebEnvironment() {
    // Check if running locally or on a server
    if (kIsWeb) {
      // Get the current window location
      final String windowLocation = _getWindowLocation();
      
      if (windowLocation.contains('localhost') || windowLocation.contains('127.0.0.1')) {
        // Local development - hit the C# API on port 5000
        _rootUrl = 'http://localhost:5000/api';
      } else {
        // Server deployment - use relative URL
        // This assumes nginx/IIS proxies /api/* to the backend
        _rootUrl = '/api';
      }
    } else {
      _rootUrl = '/api';
    }
  }

  /// Get the current window location (web only)
  static String _getWindowLocation() {
    try {
      // In real Flutter web, this would use html.window.location.href
      // Since we don't want to import 'dart:html' everywhere, we use a helper
      return Uri.base.toString();
    } catch (e) {
      return 'http://localhost:3000';
    }
  }

  /// Get the root API URL
  static String get rootUrl => _rootUrl;

  /// Get the base URL for the bingo controller
  static String get baseUrl => '$_rootUrl/bingo';

  /// Set a custom root URL (useful for testing)
  static void setRootUrl(String url) {
    _rootUrl = url;
    print('API root URL manually set to: $_rootUrl');
  }
}
