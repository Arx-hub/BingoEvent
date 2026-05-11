import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class FeedbackApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<Map<String, dynamic>>> getAllFeedback() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['feedbacks'] is List) {
          return List<Map<String, dynamic>>.from(
            (data['feedbacks'] as List).map((f) => Map<String, dynamic>.from(f)),
          );
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
