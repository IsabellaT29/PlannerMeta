import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/repositories/usuario_repository.dart';
import '../utils/password_helper.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores apenas para E-mail e Senha
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Função para autenticar o usuário
  void _autenticarUsuario() async {
    if (_formKey.currentState!.validate()) {
      
      // 1. Criptografa a senha digitada para comparar com a do banco
      String senhaCriptografada = PasswordHelper.criptografar(_senhaController.text);

      // 2. Chama o método de autenticação
      final usuarioRepo = UsuarioRepository();
      final usuarioLogado = await usuarioRepo.autenticar(
        _emailController.text, 
        senhaCriptografada
      );

      if (mounted) {
        if (usuarioLogado != null) {
          // LOGIN COM SUCESSO
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bem-vindo, ${usuarioLogado.nome}!'),
              backgroundColor: AppColors.escuro,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(usuarioId: usuarioLogado.id!), 
            ),
          );
                
        } else {
          // LOGIN FALHOU
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('E-mail ou senha incorretos.'),
              backgroundColor: AppColors.escuro, // Vermelho escuro combinando com alerta
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
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
        title: const Text('Login', style: TextStyle(color: AppColors.escuro)),
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
              const SizedBox(height: 20),
              const Icon(Icons.account_circle, size: 80, color: AppColors.escuro),
              const SizedBox(height: 40),

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
                obscureText: true, 
                decoration: _construirDecoracao('Senha'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe sua senha';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão de Entrar
              ElevatedButton(
                onPressed: _autenticarUsuario,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
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
                  'ENTRAR',
                  style: TextStyle(fontSize: 16, color: AppColors.branco, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 16),

              // Link para ir para o Cadastro
              TextButton(
                onPressed: () {
                  // Navega para a tela de cadastro quando clicado
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroScreen()),
                  );
                },
                child: const Text(
                  'Ainda não possui conta? Clique aqui para se cadastrar',
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

  // Método de decoração (Idêntico ao do Cadastro)
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