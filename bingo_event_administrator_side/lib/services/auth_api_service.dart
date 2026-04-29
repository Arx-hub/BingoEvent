import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthAPI {
  // Auth uses /api/Auth endpoint
  static String get baseUrl => '${ApiConfig.rootUrl}/Auth';

  /// Login with username and password
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Invalid username or password',
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Verify current session
  static Future<Map<String, dynamic>> verifySession(int adminId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify?adminId=$adminId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Session verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get all admin accounts (master only)
  static Future<List<Map<String, dynamic>>> getAllAdmins(int adminId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/all?adminId=$adminId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['admins'] is List) {
          return List<Map<String, dynamic>>.from(
            (data['admins'] as List).map((item) => Map<String, dynamic>.from(item)),
          );
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting admins: $e');
      return [];
    }
  }

  /// Create a new admin account (master only)
  static Future<Map<String, dynamic>> createAdmin(
    int adminId,
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/create?adminId=$adminId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Failed to create account',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create account with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update an admin account (master only)
  static Future<Map<String, dynamic>> updateAdmin(
    int adminId,
    int targetAdminId,
    String? username,
    String? password,
  ) async {
    try {
      final body = {};
      if (username != null) body['username'] = username;
      if (password != null) body['password'] = password;
      body['id'] = targetAdminId;

      final response = await http.put(
        Uri.parse('$baseUrl/admin/update?adminId=$adminId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Failed to update account',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update account with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete an admin account (master only)
  static Future<Map<String, dynamic>> deleteAdmin(int adminId, int targetAdminId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/delete/$targetAdminId?adminId=$adminId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Failed to delete account',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete account with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
