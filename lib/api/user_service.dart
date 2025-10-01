import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = "https://api.devthigas.shop";

  static Future<bool> createUser(String name, String email, String password, String role) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse("$baseUrl/users");
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "name": name,
            "email": email,
            "password": password,
            "role": role,
          }));
      return response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<dynamic>> getUsers() async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/users");
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Erro ao listar usuários");
  }

  static Future<Map<String, dynamic>> getUserById(String id) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/users/$id");
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Usuário não encontrado");
  }

  static Future<bool> updateUser(String id, String name) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/users/$id");
    final response = await http.put(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": name}));
    return response.statusCode == 200;
  }

  static Future<bool> deleteUser(String id) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/users/$id");
    final response = await http.delete(url, headers: {
      "Authorization": "Bearer $token",
    });
    return response.statusCode == 200;
  }
}
