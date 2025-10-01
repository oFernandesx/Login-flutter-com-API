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
  
  final bool _isUserAdmin = false; 

  @override
  void initState() {
    super.initState();
    loadCourses();
    if (_isUserAdmin) {
      loadUsers();
    } else {
      isLoadingUsers = false; 
    }
  }
  
  void _showSnackbar(String message, {Color color = Colors.red}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildDashboardCard({
    required Widget child,
    Color color = Colors.white,
    Color splashColor = Colors.transparent, 
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15), 
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4), 
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, 
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {}, 
          child: child,
        ),
      ),
    );
  }

  Future<void> loadUsers() async {
    if (!_isUserAdmin) return;

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
        _showSnackbar("Erro ao carregar usuários.", color: Colors.red);
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
        _showSnackbar("Erro ao carregar cursos.", color: Colors.red);
      }
    }
  }

  void editUser(String id, String currentName) {
    if (!_isUserAdmin) return;
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Usuário", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Novo Nome"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await UserService.updateUser(id, controller.text);
              if (success) {
                _showSnackbar("Usuário atualizado com sucesso!", color: Colors.green);
                loadUsers();
              } else {
                _showSnackbar("Falha ao atualizar usuário.", color: Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void deleteUser(String id) async {
    if (!_isUserAdmin) return;
    final success = await UserService.deleteUser(id);
    if (success) {
      _showSnackbar("Usuário deletado com sucesso!", color: Colors.green);
      loadUsers();
    } else {
      _showSnackbar("Falha ao deletar usuário.", color: Colors.red);
    }
  }

  void editCourse(String id, String name, String desc, double price) {
    if (!_isUserAdmin) return;
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: desc);
    final priceController = TextEditingController(text: price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Curso", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nome")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
              TextField(
                controller: priceController, 
                decoration: const InputDecoration(labelText: "Preço"), 
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
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final newPrice = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
              final success = await CourseService.updateCourse(
                  id, nameController.text, descController.text, newPrice);
              if (success) {
                _showSnackbar("Curso atualizado com sucesso!", color: Colors.green);
                loadCourses();
              } else {
                _showSnackbar("Falha ao atualizar curso.", color: Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  void deleteCourse(String id) async {
    if (!_isUserAdmin) return;
    final success = await CourseService.deleteCourse(id);
    if (success) {
      _showSnackbar("Curso deletado com sucesso!", color: Colors.green);
      loadCourses();
    } else {
      _showSnackbar("Falha ao deletar curso.", color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _isUserAdmin ? "Painel Administrativo" : "Catálogo de Cursos",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: Text(
                _isUserAdmin ? "Gestão de Conteúdo" : "Bem-vindo ao Catálogo",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              _isUserAdmin
                  ? "Gerencie usuários e cursos cadastrados no sistema."
                  : "Confira todos os cursos disponíveis e comece a aprender.",
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            const SizedBox(height: 30),

            if (_isUserAdmin) ...[
              const Text(
                "Usuários Cadastrados",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),

              isLoadingUsers
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    ))
                  : users.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Nenhum usuário encontrado.", style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return _buildDashboardCard(
                              color: Colors.blue.shade50,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
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
              const SizedBox(height: 30),
            ],

            const Text(
              "Cursos Publicados", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            isLoadingCourses
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Colors.green),
                  ))
                : courses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
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
                            color: Colors.green.shade50,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.2),
                                child: Icon(Icons.book, color: Colors.green.shade700, size: 20),
                              ),
                              title: Text(course["name"], style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                "R\$ ${price.toStringAsFixed(2)} - ${course["desc"] ?? "Sem descrição"}", 
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: _isUserAdmin 
                                ? Row( 
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
                                  )
                                : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueGrey), 
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
