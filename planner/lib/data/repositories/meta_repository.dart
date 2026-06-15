import '../database/database_helper.dart';
import '../../models/meta.dart';

class MetaRepository {
  // Pega a instância do banco de dados
  final _dbHelper = DatabaseHelper.instance;

  // BUSCAR METAS DO USUÁRIO
  Future<List<Map<String, dynamic>>> buscarMetasPorUsuario(int usuarioId) async {
    final db = await _dbHelper.database;
    
    return await db.query(
      'Meta',
      where: 'UsuarioId = ?',
      whereArgs: [usuarioId],
    );
  }

  // INSERIR NOVA META
  Future<int> inserir(Meta meta) async {
    final db = await _dbHelper.database;
    return await db.insert('Meta', meta.toMap());
  }

  // DELETAR META
  Future<int> deletar(int id) async {
    final db = await _dbHelper.database;
    
    return await db.delete(
      'Meta',
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  // ATUALIZAR META
  Future<int> atualizar(int id, String descricao, String prazo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Meta',
      {'Descricao': descricao, 'Prazo': prazo},
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  Future<String> buscarNomeUsuario(int usuarioId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Usuario',
      columns: ['Nome'],
      where: 'Id = ?',
      whereArgs: [usuarioId],
    );
    
    if (result.isNotEmpty) {
      return result.first['Nome'] as String;
    }
    return 'Usuário';
  }

  // No futuro, você pode adicionar aqui o inserir() e o atualizar()
}