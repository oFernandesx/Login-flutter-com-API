import 'package:flutter/material.dart';
import '../api/user_service.dart';
import '../api/course_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<dynamic> users = [];
  List<dynamic> courses = [];
  bool isLoadingUsers = true;
  bool isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadCourses();
  }

  Future<void> loadUsers() async {
    try {
      final data = await UserService.getUsers();
      setState(() {
        users = data;
        isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => isLoadingUsers = false);
      print("Erro ao carregar usuários: $e");
    }
  }

  Future<void> loadCourses() async {
    try {
      final data = await CourseService.getCourses();
      setState(() {
        courses = data;
        isLoadingCourses = false;
      });
    } catch (e) {
      setState(() => isLoadingCourses = false);
      print("Erro ao carregar cursos: $e");
    }
  }

  void editUser(String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Usuário"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              final success = await UserService.updateUser(id, controller.text);
              if (success) {
                Navigator.pop(context);
                loadUsers();
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  void deleteUser(String id) async {
    final success = await UserService.deleteUser(id);
    if (success) loadUsers();
  }

  void editCourse(String id, String name, String desc, double price) {
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: desc);
    final priceController = TextEditingController(text: price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Curso"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Preço"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final success = await CourseService.updateCourse(
                  id, nameController.text, descController.text, double.parse(priceController.text));
              if (success) {
                Navigator.pop(context);
                loadCourses();
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  void deleteCourse(String id) async {
    final success = await CourseService.deleteCourse(id);
    if (success) loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Usuários", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            isLoadingUsers
                ? const CircularProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user["name"]),
                        subtitle: Text(user["email"]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => editUser(user["id"], user["name"])),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteUser(user["id"])),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 20),
            const Text("Cursos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            isLoadingCourses
                ? const CircularProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return ListTile(
                        title: Text(course["name"]),
                        subtitle: Text(course["desc"] ?? ""),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => editCourse(course["id"], course["name"], course["desc"] ?? "", (course["price"] ?? 0).toDouble())),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteCourse(course["id"])),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
