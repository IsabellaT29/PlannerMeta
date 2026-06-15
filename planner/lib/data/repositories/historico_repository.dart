import '../database/database_helper.dart';

class HistoricoRepository {
  final _dbHelper = DatabaseHelper.instance;

  // REGISTRAR QUE CUMPRIU HOJE
  Future<int> registrarCumprimento(int micrometaId) async {
    final db = await _dbHelper.database;
    return await db.insert('Historico_Cumprimento', {
      'MicrometaId': micrometaId,
      'Data_Realizacao': DateTime.now().toIso8601String(), 
    });
  }

  // DESMARCAR CUMPRIMENTO DE HOJE
  Future<int> removerCumprimentoHoje(int micrometaId) async {
    final db = await _dbHelper.database;
    String hoje = DateTime.now().toIso8601String().substring(0, 10); // Pega só o YYYY-MM-DD
    
    return await db.delete(
      'Historico_Cumprimento',
      // O LIKE garante que vai deletar qualquer registro que comece com a data de hoje
      where: 'MicrometaId = ? AND Data_Realizacao LIKE ?',
      whereArgs: [micrometaId, '$hoje%'],
    );
  }

  // VERIFICAR SE JÁ FOI CUMPRIDA HOJE
  Future<bool> verificouHoje(int micrometaId) async {
    final db = await _dbHelper.database;
    String hoje = DateTime.now().toIso8601String().substring(0, 10);
    
    final result = await db.query(
      'Historico_Cumprimento',
      where: 'MicrometaId = ? AND Data_Realizacao LIKE ?',
      whereArgs: [micrometaId, '$hoje%'],
    );
    return result.isNotEmpty;
  }

  // CONTAR TOTAL DE VEZES
  Future<int> contarCumprimentos(int micrometaId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM Historico_Cumprimento WHERE MicrometaId = ?',
      [micrometaId],
    );
    return result.first['total'] as int;
  }
}