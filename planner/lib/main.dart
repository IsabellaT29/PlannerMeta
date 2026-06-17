import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ativa o banco de dados na memória do navegador se estiver a rodar no Chrome
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

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