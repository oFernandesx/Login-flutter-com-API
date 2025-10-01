import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/cadastrar_usuario.dart';
import 'package:flutter_application_1/ui/loginpage.dart';
import 'package:flutter_application_1/ui/homepage.dart';
import 'package:flutter_application_1/ui/create_couse.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/",
      routes: {
        "/": (context) => const LoginPage(),
        "/home": (context) => const HomePage(),
        "/createCourse": (context) => const CreateCoursePage(),
        "/createUser": (context) => const CreateUserPage(), // ✅
      },
    );
  }
}
