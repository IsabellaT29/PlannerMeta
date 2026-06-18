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

// Busca APENAS ATIVAS de todas as metas para a tela de Rotina Diária (Home)
Future<List<Map<String, dynamic>>> buscarTodasAtivasGerais() async {
  final db = await _dbHelper.database;
  return await db.query('Micrometas', where: 'Ativo = 1');
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

  // trazer o nome da meta pai
  Future<List<Map<String, dynamic>>> buscarTodasAtivasComNomeMeta() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT M.Id, M.MetaId, M.Descricao, M.FrequenciaId, M.Dia_Especifico, MT.Descricao as NomeMeta
      FROM Micrometas M
      INNER JOIN Meta MT ON M.MetaId = MT.Id
      WHERE M.Ativo = 1
    ''');
  }
}