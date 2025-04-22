import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'app_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Clients table
    await db.execute('''
      CREATE TABLE cadastros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        endereco TEXT NOT NULL
      )
    ''');

    // Services table
    await db.execute('''
      CREATE TABLE servicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente TEXT NOT NULL,
        descricao TEXT NOT NULL,
        data TEXT NOT NULL,
        horas REAL NOT NULL,
        valor_unitario REAL NOT NULL,
        valor_total REAL NOT NULL,
        FOREIGN KEY(cliente) REFERENCES cadastros(nome)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE servicos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cliente TEXT NOT NULL,
          descricao TEXT NOT NULL,
          data TEXT NOT NULL,
          horas REAL NOT NULL,
          valor_unitario REAL NOT NULL,
          valor_total REAL NOT NULL
        )
      ''');
    }
  }
  Future<int> insertCadastro(Map<String, dynamic> client) async {
    final db = await database;
    return await db.insert('cadastros', client);
  }

  Future<List<Map<String, dynamic>>> getAllCadastros() async {
    final db = await database;
    return await db.query('cadastros', orderBy: 'nome ASC');
  }

  Future<List<String>> getNomesClientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cadastros');
    return List<String>.generate(maps.length, (i) => maps[i]['nome'] as String);
  }

  Future<int> deleteCadastro(int id) async {
    final db = await database;
    return await db.delete(
      'cadastros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertServico(Map<String, dynamic> service) async {
    final db = await database;
    return await db.insert('servicos', service);
  }

  Future<List<Map<String, dynamic>>> getAllServicos() async {
    final db = await database;
    return await db.query('servicos', orderBy: 'data DESC');
  }

  Future<List<Map<String, dynamic>>> getServicosPorCliente(String clientName) async {
    final db = await database;
    return await db.query(
      'servicos',
      where: 'cliente = ?',
      whereArgs: [clientName],
      orderBy: 'data DESC',
    );
  }

  Future<int> updateServico(int id, Map<String, dynamic> service) async {
    final db = await database;
    return await db.update(
      'servicos',
      service,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteServico(int id) async {
    final db = await database;
    return await db.delete(
      'servicos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}