import 'package:http/http.dart' as http;
import 'dart:convert';

class WelcomePageAPI {
  static const String baseUrl = 'http://localhost/api/bingo';

  static Future<Map<String, dynamic>> saveWelcomePage({
    required String name,
    required String title,
    String subtitle = '',
    int? id,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/welcome-pages');
      final Map<String, dynamic> bodyMap = {
        'name': name,
        'title': title,
        'subtitle': subtitle,
      };
      if (id != null) {
        bodyMap['id'] = id;
      }
      final body = jsonEncode(bodyMap);

      print('[WelcomePageAPI] saveWelcomePage: POST $url');
      print('[WelcomePageAPI] saveWelcomePage body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      print('[WelcomePageAPI] saveWelcomePage response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to save welcome page: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[WelcomePageAPI] saveWelcomePage error: $e');
      throw Exception('Error saving welcome page: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllWelcomePages() async {
    try {
      final url = Uri.parse('$baseUrl/welcome-pages');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['welcomePages'] != null) {
          return List<Map<String, dynamic>>.from(data['welcomePages']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get welcome pages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting welcome pages: $e');
    }
  }

  static Future<bool> deleteWelcomePage(int id) async {
    try {
      final url = Uri.parse('$baseUrl/welcome-pages/$id');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to delete welcome page: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting welcome page: $e');
    }
  }
}
