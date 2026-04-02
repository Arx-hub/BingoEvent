import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionPackageAPI {
  static const String baseUrl = 'http://localhost/api/bingo';

  static Future<List<Map<String, dynamic>>> getAllQuestionPackages() async {
    try {
      final url = Uri.parse('$baseUrl/question-packages');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['questionPackages'] != null) {
          return List<Map<String, dynamic>>.from(data['questionPackages']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get question packages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting question packages: $e');
    }
  }

  static Future<Map<String, dynamic>> saveQuestionPackage({
    required String name,
    required List<Map<String, dynamic>> questions,
    int? id,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/question-packages');
      final Map<String, dynamic> bodyMap = {
        'name': name,
        'questions': questions,
      };
      if (id != null) {
        bodyMap['id'] = id;
      }
      final body = jsonEncode(bodyMap);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to save question package');
      }
    } catch (e) {
      throw Exception('Error saving question package: $e');
    }
  }

  static Future<Map<String, dynamic>> duplicateQuestionPackage(int id) async {
    try {
      final url = Uri.parse('$baseUrl/question-packages/$id/duplicate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to duplicate question package: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error duplicating question package: $e');
    }
  }

  static Future<bool> deleteQuestionPackage(int id) async {
    try {
      final url = Uri.parse('$baseUrl/question-packages/$id');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to delete question package: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting question package: $e');
    }
  }
}
