import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/usuario.dart';
import '../data/repositories/usuario_repository.dart';
import '../utils/password_helper.dart';
import 'login_screen.dart'; 

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para capturar o texto digitado
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Função chamada ao clicar no botão de salvar
  void _salvarUsuario() async {
    // Verifica se todos os campos passaram na validação
    if (_formKey.currentState!.validate()) {
      
      // 1. Criptografa a senha digitada
      String senhaCriptografada = PasswordHelper.criptografar(_senhaController.text);

      // 2. Cria o objeto Usuario com a senha já protegida
      Usuario novoUsuario = Usuario(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: senhaCriptografada,
      );

      // 3. Salva no banco de dados SQLite
      final usuarioRepo = UsuarioRepository();
      await usuarioRepo.inserir(novoUsuario);

      // 4. Mostra um aviso de sucesso e limpa o formulário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário cadastrado com sucesso! Faça seu login.'),
            backgroundColor: AppColors.escuro,
          ),
        );
        _nomeController.clear();
        _emailController.clear();
        _senhaController.clear();

        // Aguarda 1 segundo e força a substituição da tela pela de Login
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.claro,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cadastro', style: TextStyle(color: AppColors.escuro)),
        backgroundColor: AppColors.medio,
        iconTheme: const IconThemeData(color: AppColors.escuro),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_circle, size: 80, color: AppColors.escuro),
              const SizedBox(height: 32),

              // Campo Nome
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: AppColors.escuro), 
                decoration: _construirDecoracao('Nome Completo'),
                validator: (value) => value!.isEmpty ? 'Informe o seu nome' : null,
              ),
              const SizedBox(height: 16),

              // Campo E-mail
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.escuro), 
                keyboardType: TextInputType.emailAddress,
                decoration: _construirDecoracao('E-mail'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o seu e-mail';
                  if (!value.contains('@')) return 'Informe um e-mail válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Senha
              TextFormField(
                controller: _senhaController,
                style: const TextStyle(color: AppColors.escuro), 
                obscureText: true, // Esconde a senha digitada
                decoration: _construirDecoracao('Senha'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe uma senha';
                  if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão de Cadastrar
              ElevatedButton(
                onPressed: _salvarUsuario,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        // NOVO TOM DE HOVER: Um vinho ligeiramente mais claro, sem ficar preto
                        return const Color(0xFF6B2036); 
                      }
                      return AppColors.escuro; 
                    },
                  ),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                child: const Text(
                  'CADASTRAR',
                  style: TextStyle(fontSize: 16, color: AppColors.branco, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 16),

              // Texto clicável para Login
              TextButton(
                onPressed: () {
                  // Força a substituição da tela pela de Login ao clicar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Já possui cadastro? Clique aqui para fazer o login',
                  style: TextStyle(
                    color: AppColors.escuro,
                    fontWeight: FontWeight.w600, 
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método auxiliar para não repetir o código de design das bordas dos campos
  InputDecoration _construirDecoracao(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.escuro),
      filled: true,
      fillColor: AppColors.branco,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.escuro),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.medio),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.escuro, width: 2),
      ),
    );
  }
}