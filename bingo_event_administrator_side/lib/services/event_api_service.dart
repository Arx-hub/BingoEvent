import 'package:http/http.dart' as http;
import 'dart:convert';

class EventAPI {
  static const String baseUrl = 'http://localhost/api/bingo';

  static Future<Map<String, dynamic>> saveEvent({
    required String name,
    required String creator,
    required int welcomePageId,
    required int bingoBoardId,
    required List<String> gameNames,
    int? questionPackageId,
    int? id,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/events');
      final Map<String, dynamic> bodyMap = {
        'name': name,
        'creator': creator,
        'welcomePageId': welcomePageId,
        'bingoBoardId': bingoBoardId,
        'gameNames': gameNames,
        'questionPackageId': questionPackageId,
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
        throw Exception('Failed to save event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving event: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final url = Uri.parse('$baseUrl/events');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['events'] != null) {
          return List<Map<String, dynamic>>.from(data['events']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting events: $e');
    }
  }

  static Future<bool> deleteEvent(int id) async {
    try {
      final url = Uri.parse('$baseUrl/events/$id');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to delete event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }
}
