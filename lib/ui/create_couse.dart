import 'package:flutter/material.dart';
import '../api/course_service.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  _CreateCoursePageState createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  bool isLoading = false;

  void createCourse() async {
    setState(() => isLoading = true);

    try {
      await CourseService.createCourse(
        nameController.text,
        descController.text,
        double.parse(priceController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Curso criado com sucesso!")),
      );

      Navigator.pop(context); // volta pra Home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Curso")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nome do curso"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Descrição"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Preço"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createCourse,
                    child: const Text("Salvar"),
                  ),
          ],
        ),
      ),
    );
  }
}
