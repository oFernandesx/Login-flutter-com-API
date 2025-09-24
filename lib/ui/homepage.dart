import 'package:flutter/material.dart';
import '../api/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/");
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Bem-vindo! Você está logado 🚀",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
