//Classes auxiliares do histórico

class GrupoMicrometaExistente {
  String descricao;
  int frequenciaId;
  int frequenciaOriginal; 
  Map<int, int> diasOriginais; 
  List<int> diasSelecionados;

  GrupoMicrometaExistente({
    required this.descricao,
    required this.frequenciaId,
    required this.frequenciaOriginal,
    required this.diasOriginais,
    required this.diasSelecionados,
  });
}

class MicrometaNova {
  String descricao = '';
  int frequenciaId = 1;
  List<int> diasSemana = [];
  List<int> diasMes = [];
}