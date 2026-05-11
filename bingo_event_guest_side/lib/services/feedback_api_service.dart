import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class FeedbackAPI {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<bool> submitFeedback(int rating, String eventPackageName) async {
    try {
      final url = Uri.parse('$baseUrl/feedback');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rating': rating,
          'eventPackageName': eventPackageName,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
