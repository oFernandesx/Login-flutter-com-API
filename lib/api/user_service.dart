import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = "https://api.devthigas.shop";

  // ✅ Criar usuário (apenas ADMIN)
  static Future<bool> createUser(String name, String email, String password, String role) async {
    try {
      final token = await AuthService.getToken(); // Token salvo no login
      final url = Uri.parse("$baseUrl/users");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role, // Ex: "USER" ou "ADMIN"
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("Erro ao criar usuário: $e");
      return false;
    }
  }
}
