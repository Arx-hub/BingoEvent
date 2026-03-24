import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Use localhost:5000 for local Docker access from host browser
  // The API is exposed on port 5000 in docker-compose.yml
  static String baseUrl = 'http://localhost:5000/api/bingo';

  /// Sets the base URL for the API service (useful for switching environments)
  static void setBaseUrl(String url) {
    baseUrl = url;
    print('API base URL set to: $baseUrl');
  }

  /// Creates a new bingo board and saves it to the database
  static Future<Map<String, dynamic>> createBingoBoard(
    String boardName,
    List<String> textContent,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/issue-board'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'boardName': boardName,
          'textContent': textContent,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Board created successfully: $data');
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create board: ${response.body}');
      }
    } catch (e) {
      print('Error creating board: $e');
      rethrow;
    }
  }

  /// Retrieves all bingo boards
  static Future<List<Map<String, dynamic>>> getAllBoards() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/boards'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Handle both direct list and wrapped response
        List<dynamic> boardsList;
        if (decoded is List) {
          boardsList = decoded;
        } else if (decoded is Map && decoded.containsKey('boards')) {
          boardsList = decoded['boards'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }
        
        print('Boards retrieved successfully: ${boardsList.length} boards');
        return List<Map<String, dynamic>>.from(boardsList);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get boards: ${response.body}');
      }
    } catch (e) {
      print('Error getting boards: $e');
      rethrow;
    }
  }

  /// Retrieves a specific bingo board by ID
  static Future<Map<String, dynamic>> getBoardById(int boardId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/board/$boardId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Board retrieved successfully: $data');
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get board: ${response.body}');
      }
    } catch (e) {
      print('Error getting board: $e');
      rethrow;
    }
  }

  /// Updates the text of a specific cell
  static Future<Map<String, dynamic>> updateText(
    int boardId,
    int row,
    int column,
    String newText,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-text'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'boardId': boardId,
          'row': row,
          'column': column,
          'newText': newText,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Text updated successfully: $data');
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update text: ${response.body}');
      }
    } catch (e) {
      print('Error updating text: $e');
      rethrow;
    }
  }

  /// Marks a box on the bingo board
  static Future<Map<String, dynamic>> markBox(
    int boardId,
    int row,
    int column,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mark-box'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'boardId': boardId,
          'row': row,
          'column': column,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Box marked successfully: $data');
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to mark box: ${response.body}');
      }
    } catch (e) {
      print('Error marking box: $e');
      rethrow;
    }
  }
}
