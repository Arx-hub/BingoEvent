import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = '/api/bingo';

  static Future<bool> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/admin/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
