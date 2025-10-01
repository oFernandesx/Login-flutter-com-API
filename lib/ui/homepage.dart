import 'package:flutter/material.dart';
import '../api/course_service.dart';
import '../api/user_service.dart';
import '../api/auth_service.dart';

// Assuming you have simple data models (classes) for better type safety
// For demonstration, we'll stick to Map<String, dynamic> but keep the code clean.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // --- Utility Functions with `mounted` Check and UI Feedback ---

  Future<void> loadUsers() async {
    try {
      final data = await UserService.getUsers();
      if (mounted) {
        setState(() {
          users = data;
          isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingUsers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar usuários: $e")),
        );
      }
    }
  }

  Future<void> loadCourses() async {
    try {
      final data = await CourseService.getCourses();
      if (mounted) {
        setState(() {
          courses = data;
          isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingCourses = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar cursos: $e")),
        );
      }
    }
  }

  void logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  // Utility to show success/error message
  void showFeedback(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // --- CRUD Handlers ---

  void editUser(String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Usuário", style: TextStyle(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nome"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await UserService.updateUser(id, controller.text);
              if (success) {
                showFeedback("Usuário atualizado com sucesso!");
                loadUsers();
              } else {
                showFeedback("Falha ao atualizar usuário.", isError: true);
              }
            },
            child: const Text("Salvar", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void deleteUser(String id) async {
    final success = await UserService.deleteUser(id);
    if (success) {
      showFeedback("Usuário deletado com sucesso!");
      loadUsers();
    } else {
      showFeedback("Falha ao deletar usuário.", isError: true);
    }
  }

  void editCourse(String id, String name, String desc, double price) {
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: desc);
    // Use an input formatter or more robust validation in a real app
    final priceController = TextEditingController(text: price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Curso", style: TextStyle(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView( // Add SingleChildScrollView for better compatibility
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nome")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Preço (Ex: 99.99)"),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final newPrice = double.tryParse(priceController.text) ?? 0.0;
              final success = await CourseService.updateCourse(
                  id, nameController.text, descController.text, newPrice);
              if (success) {
                showFeedback("Curso atualizado com sucesso!");
                loadCourses();
              } else {
                showFeedback("Falha ao atualizar curso.", isError: true);
              }
            },
            child: const Text("Salvar", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void deleteCourse(String id) async {
    final success = await CourseService.deleteCourse(id);
    if (success) {
      showFeedback("Curso deletado com sucesso!");
      loadCourses();
    } else {
      showFeedback("Falha ao deletar curso.", isError: true);
    }
  }

  // --- UI Widgets for Minimalist Design ---

  Widget _buildActionButton(
      {required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1), // Subtle background color
        ),
        child: TextButton.icon(
          icon: Icon(icon, color: color),
          label: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove padding to let the container handle it
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // A custom card for a cleaner look
  Widget _buildDashboardCard({
    required Widget child,
    Color color = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3), // subtle shadow lift
          ),
        ],
      ),
      child: child,
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light gray background for contrast
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Modern bold title
          ),
        ),
        centerTitle: false, // Left alignment for modern apps
        backgroundColor: Colors.white,
        elevation: 0.5, // Subtle separation from the body
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: logout,
            tooltip: "Sair",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // Increased padding for more white space
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== BOTÕES DE AÇÃO (Action Buttons) =====
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.person_add_alt_1,
                  label: "Novo Usuário",
                  color: Colors.blue.shade600,
                  onPressed: () =>
                      Navigator.pushNamed(context, "/createUser").then((_) => loadUsers()),
                ),
                const SizedBox(width: 15),
                _buildActionButton(
                  icon: Icons.auto_stories,
                  label: "Novo Curso",
                  color: Colors.green.shade600,
                  onPressed: () =>
                      Navigator.pushNamed(context, "/createCourse").then((_) => loadCourses()),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---
            
            // ===== LISTA DE USUÁRIOS (User List) =====
            _buildSectionHeader("Usuários"),
            isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Nenhum usuário encontrado.", style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _buildDashboardCard(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: Text(user["name"][0].toUpperCase(), style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(user["name"], style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(user["email"], style: const TextStyle(color: Colors.grey)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                      onPressed: () => editUser(user["id"], user["name"])),
                                  IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => deleteUser(user["id"])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

            // ---

            // ===== LISTA DE CURSOS (Course List) =====
            _buildSectionHeader("Cursos"),
            isLoadingCourses
                ? const Center(child: CircularProgressIndicator())
                : courses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Nenhum curso encontrado.", style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final price = (course["price"] ?? 0.0).toDouble();
                          return _buildDashboardCard(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.1),
                                child: const Icon(Icons.book_rounded, color: Colors.green),
                              ),
                              title: Text(course["name"], style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                "${course["desc"] ?? "Sem descrição"} - R\$ ${price.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis, // Clean up long descriptions
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                      onPressed: () => editCourse(
                                          course["id"], course["name"], course["desc"] ?? "", price)),
                                  IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => deleteCourse(course["id"])),
                                ],
                              ),
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