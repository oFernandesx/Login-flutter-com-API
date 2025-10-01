import 'package:flutter/material.dart';
import '../api/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ou senha inválidos"),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Novo widget para campo de texto moderno e elevado
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required FocusNode focusNode,
    TextInputAction? textInputAction,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.emailAddress,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
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
        // Estilo de borda moderno: arredondada e sutil
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Remove a borda padrão para um visual mais limpo
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600, // Ajustado para ser menos pesado que 'bold'
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2, // Aumenta a elevação para dar a sensação de Material Design
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32), // Aumenta o padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título principal (H1)
              const Text(
                "Bem-vindo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Acesse sua conta com suas credenciais.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 48),

              // ===== Bloco de Campos de Texto (Modern Card Style) =====
              Card(
                elevation: 10, // Sombra forte para o bloco de login
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Email
                      _buildModernTextField(
                        controller: emailController,
                        hintText: "Email",
                        focusNode: _emailFocus,
                        icon: Icons.alternate_email,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      // Senha
                      _buildModernTextField(
                        controller: passwordController,
                        hintText: "Senha",
                        focusNode: _passwordFocus,
                        icon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text, // Mudar para texto para teclado QWERTY
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ===== Botão de Login Moderno (Elevated) =====
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [ // Sombra no botão para efeito "flutuante"
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Cor primária forte
                          foregroundColor: Colors.white,
                          elevation: 0, // A elevação é dada pelo Container para controle da sombra
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Entrar"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
