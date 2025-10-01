import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "https://api.devthigas.shop";

  static Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data["accessToken"] ?? data["token"];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);

          // salva info do usuário
          await prefs.setString("role", data["role"] ?? "USER");
          await prefs.setString("email", data["email"] ?? "");
          await prefs.setString("id", data["id"] ?? "");

          return true;
        }
      }
      return false;
    } catch (e) {
      print("Erro no login: $e");
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }
}
