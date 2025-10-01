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

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // Widget reutilizável para campos de texto com estilo moderno (elevado e arredondado)
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputAction? textInputAction,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      cursorColor: Colors.blueAccent,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
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

  void createCourse() async {
    FocusScope.of(context).unfocus();

    if (nameController.text.isEmpty || descController.text.isEmpty || priceController.text.isEmpty) {
      _showSnackbar("Por favor, preencha todos os campos.");
      return;
    }

    // Tenta analisar o preço, permitindo vírgula (,) ou ponto (.)
    final priceString = priceController.text.replaceAll(',', '.');
    final price = double.tryParse(priceString);

    if (price == null || price <= 0) {
      _showSnackbar("Preço inválido. Use um número positivo.");
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      await CourseService.createCourse(
        nameController.text,
        descController.text,
        price,
      );

      _showSnackbar("Curso criado com sucesso!", color: Colors.green);

      if (mounted) {
        Navigator.pop(context); // volta pra Home
      }
    } catch (e) {
      _showSnackbar("Erro ao criar curso: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Criar Curso",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              const Text(
                "Novo Curso",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Insira as informações do novo material didático.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 48),

              // ===== Bloco de Formulário (Modern Card Style) =====
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nome do Curso
                      _buildModernTextField(
                        controller: nameController,
                        hintText: "Nome do curso (ex: Flutter Avançado)",
                        icon: Icons.auto_stories,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      // Descrição
                      _buildModernTextField(
                        controller: descController,
                        hintText: "Descrição detalhada do curso",
                        icon: Icons.description,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 20),
                      // Preço
                      _buildModernTextField(
                        controller: priceController,
                        hintText: "Preço (ex: 99.99)",
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ===== Botão de Salvar Moderno (Elevated) =====
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4), // Sombra verde para criar contraste
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: createCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Cor primária forte (Verde para "Criar")
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Salvar Curso"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
