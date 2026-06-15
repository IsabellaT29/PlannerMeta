import '../database/database_helper.dart';
import '../../models/micrometa.dart';

class MicrometaRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> inserir(Micrometa micrometa) async {
    final db = await _dbHelper.database;
    return await db.insert('Micrometas', micrometa.toMap());
  }

  // Busca TODAS (Ativas e Inativas) para a tela de Ver Meta (Histórico Completo)
  Future<List<Map<String, dynamic>>> buscarTodasPorMeta(int metaId) async {
    final db = await _dbHelper.database;
    return await db.query('Micrometas', where: 'MetaId = ?', whereArgs: [metaId]);
  }

  // Busca APENAS ATIVAS para a tela de Edição
  Future<List<Map<String, dynamic>>> buscarAtivasPorMeta(int metaId) async {
    final db = await _dbHelper.database;
    return await db.query('Micrometas', where: 'MetaId = ? AND Ativo = 1', whereArgs: [metaId]);
  }

  Future<int> atualizarCompleto(int id, String descricao, int frequenciaId, int? diaEspecifico) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Micrometas',
      {'Descricao': descricao, 'FrequenciaId': frequenciaId, 'Dia_Especifico': diaEspecifico},
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  // EXCLUSÃO LÓGICA 
  Future<int> inativar(int id) async {
    final db = await _dbHelper.database;
    return await db.update('Micrometas', {'Ativo': 0}, where: 'Id = ?', whereArgs: [id]);
  }
}