import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DatabaseHelper {

  // Padrão Singleton
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meu_banco.db');
    return _database!;
  }

  
  Future _createDB(Database db, int version) async {

    // 1. Tabela Frequencia
    await db.execute('''
      CREATE TABLE Frequencia (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Descricao TEXT NOT NULL
      )
    ''');

    // Inserindo os valores padrão na tabela Frequencia
    await db.execute('''
      INSERT INTO Frequencia (Descricao) 
      VALUES ('Diário'), ('Semanal'), ('Mensal')
    ''');

    // 2. Tabela Usuario
    await db.execute('''
      CREATE TABLE Usuario (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Nome TEXT NOT NULL,
        Email TEXT NOT NULL,
        Senha TEXT NOT NULL
      )
    ''');

    // 3. Tabela Meta
    await db.execute('''
      CREATE TABLE Meta (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        UsuarioId INTEGER NOT NULL,
        Descricao TEXT NOT NULL,
        Prazo TEXT NOT NULL,
        FOREIGN KEY (UsuarioId) REFERENCES Usuario (Id) ON DELETE CASCADE
      )
    ''');

    // 4. Tabela Micrometas
    await db.execute('''
      CREATE TABLE Micrometas (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        MetaId INTEGER NOT NULL,
        FrequenciaId INTEGER NOT NULL,
        Descricao TEXT NOT NULL,
        Dia_Especifico INTEGER,
        FOREIGN KEY (MetaId) REFERENCES Meta (Id) ON DELETE CASCADE,
        FOREIGN KEY (FrequenciaId) REFERENCES Frequencia (Id)
      )
    ''');

    // 5. Tabela Historico_Cumprimento
    await db.execute('''
      CREATE TABLE Historico_Cumprimento (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        MicrometaId INTEGER NOT NULL,
        Data_Realizacao TEXT NOT NULL,
        FOREIGN KEY (MicrometaId) REFERENCES Micrometas (Id) ON DELETE CASCADE
      )
    ''');
  }


  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure, // Adicione esta linha
      onCreate: _createDB,
    );
  }

  // Crie este método para ligar as Foreign Keys
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}