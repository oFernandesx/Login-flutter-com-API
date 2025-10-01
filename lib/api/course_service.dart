import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CourseService {
  static const String baseUrl = "https://api.devthigas.shop";

  static Future<List<dynamic>> getCourses() async {
    final url = Uri.parse("$baseUrl/courses");
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Erro ao buscar cursos");
  }

  static Future<bool> createCourse(String name, String desc, double price) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/courses");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": name, "desc": desc, "price": price}));
    return response.statusCode == 201;
  }

  static Future<bool> updateCourse(String id, String name, String desc, double price) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/courses/$id");
    final response = await http.put(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": name, "desc": desc, "price": price}));
    return response.statusCode == 200;
  }

  static Future<bool> deleteCourse(String id) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl/courses/$id");
    final response = await http.delete(url, headers: {
      "Authorization": "Bearer $token",
    });
    return response.statusCode == 200;
  }
}
