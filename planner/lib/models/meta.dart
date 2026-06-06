class Meta {
  final int? id;
  final int usuarioId;
  final String descricao;
  final String prazo; 

  Meta({
    this.id,
    required this.usuarioId,
    required this.descricao,
    required this.prazo,
  });

  factory Meta.fromMap(Map<String, dynamic> map) {
    return Meta(
      id: map['Id'] as int?,
      usuarioId: map['UsuarioId'] as int,
      descricao: map['Descricao'] as String,
      prazo: map['Prazo'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'Id': id,
      'UsuarioId': usuarioId,
      'Descricao': descricao,
      'Prazo': prazo,
    };
  }
}