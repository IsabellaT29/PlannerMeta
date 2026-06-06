import '../database/database_helper.dart';
import '../../models/usuario.dart';

class UsuarioRepository {

  // Pega a instância do banco de dados
  final _dbHelper = DatabaseHelper.instance;

  // INSERIR
  Future<int> inserir(Usuario usuario) async {
    final db = await _dbHelper.database;
    return await db.insert('Usuario', usuario.toMap());
  }

  // AUTENTICAR
  Future<Usuario?> autenticar(String email, String senhaCriptografada) async {
    final db = await _dbHelper.database;
    
    final result = await db.query(
      'Usuario',
      where: 'Email = ? AND Senha = ?',
      whereArgs: [email, senhaCriptografada],
    );

    // Se encontrou algum registro, converte o primeiro resultado num objeto Usuario
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    
    // Se não encontrou, retorna nulo (login falhou)
    return null; 
  }





}