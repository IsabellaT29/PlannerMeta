import 'package:flutter/material.dart';
import 'screens/cadastro_screen.dart'; 
import 'screens/login_screen.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuApp());

}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Metas',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
      ),
      // Aqui dizemos qual é a tela inicial!
      home: const LoginScreen(),
    );
  }
}