import 'package:http/http.dart' as http;
import 'dart:convert';

class BingoBoardAPI {
  static const String baseUrl = 'http://localhost:5000/api/bingo';
  
  // Save a bingo board to the database
  static Future<Map<String, dynamic>> saveBoard({
    required String name,
    required List<String> boxes,
    int? id,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/save-board');
      final body = jsonEncode({
        'id': id,
        'name': name,
        'boxes': boxes,
        'isActive': true,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to save board: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving board: $e');
    }
  }

  // Load a specific bingo board by ID
  static Future<Map<String, dynamic>> loadBoard(int id) async {
    try {
      final url = Uri.parse('$baseUrl/load-board/$id');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Board not found');
      } else {
        throw Exception('Failed to load board: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading board: $e');
    }
  }

  // Get all bingo boards
  static Future<List<Map<String, dynamic>>> getAllBoards() async {
    try {
      final url = Uri.parse('$baseUrl/boards');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['boards'] != null) {
          return List<Map<String, dynamic>>.from(data['boards']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get boards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting boards: $e');
    }
  }

  // Delete a bingo board
  static Future<bool> deleteBoard(int id) async {
    try {
      final url = Uri.parse('$baseUrl/board/$id');
      
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to delete board: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting board: $e');
    }
  }
}
