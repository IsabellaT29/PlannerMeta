import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHelper {

  static String criptografar(String senha) {
    // Converte a senha para bytes
    var bytes = utf8.encode(senha);

    // Gera o hash SHA-256
    var digest = sha256.convert(bytes);
    
    // Retorna a string criptografada
    return digest.toString();
  }

}