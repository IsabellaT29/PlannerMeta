import 'package:flutter/material.dart';
import 'screens/cadastro_screen.dart'; 
import 'screens/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), 
      ],

      // Aqui dizemos qual é a tela inicial!
      home: const LoginScreen(),
    );
  }
}