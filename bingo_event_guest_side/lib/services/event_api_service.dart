import 'package:http/http.dart' as http;
import 'dart:convert';

class EventAPI {
  static const String baseUrl = 'http://localhost:5000/api/bingo';

  static Future<Map<String, dynamic>?> getPublishedEvent() async {
    try {
      final url = Uri.parse('$baseUrl/published-event');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
