import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionPackageAPI {
  static const String baseUrl = 'http://localhost/api/bingo';

  static Future<Map<String, dynamic>?> getQuestionPackage(int id) async {
    try {
      final url = Uri.parse('$baseUrl/question-packages/$id');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['questionPackage'] != null) {
          return Map<String, dynamic>.from(data['questionPackage']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
