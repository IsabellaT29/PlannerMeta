class Usuario {
  final int? id; 
  final String nome;
  final String email;
  final String senha;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  // Transforma o Map que vem do banco de dados num objeto Usuario
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['Id'] as int?,
      nome: map['Nome'] as String,
      email: map['Email'] as String,
      senha: map['Senha'] as String,
    );
  }

  // Transforma o objeto Usuario num Map para ser guardado no banco de dados
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'Id': id,
      'Nome': nome,
      'Email': email,
      'Senha': senha,
    };
  }
}