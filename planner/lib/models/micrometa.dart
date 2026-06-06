class Micrometa {
  final int? id;
  final int metaId;
  final int frequenciaId;
  final String descricao;
  final int? diaEspecifico; 
  Micrometa({
    this.id,
    required this.metaId,
    required this.frequenciaId,
    required this.descricao,
    this.diaEspecifico,
  });

  factory Micrometa.fromMap(Map<String, dynamic> map) {
    return Micrometa(
      id: map['Id'] as int?,
      metaId: map['MetaId'] as int,
      frequenciaId: map['FrequenciaId'] as int,
      descricao: map['Descricao'] as String,
      diaEspecifico: map['Dia_Especifico'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'Id': id,
      'MetaId': metaId,
      'FrequenciaId': frequenciaId,
      'Descricao': descricao,
      'Dia_Especifico': diaEspecifico, 
    };
  }
}