import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackAPI {
  static const String baseUrl = '/api/bingo';

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
