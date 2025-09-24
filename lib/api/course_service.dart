import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CourseService {
  static const String baseUrl = "https://api.devthigas.shop";

  static Future<List<dynamic>> getCourses() async {
    final url = Uri.parse("$baseUrl/courses");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao buscar cursos: ${response.body}");
    }
  }

  static Future<void> createCourse(String name, String desc, double price) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/courses");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "desc": desc,
        "price": price,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao criar curso: ${response.body}");
    }
  }
}
