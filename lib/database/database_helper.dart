import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/servico.dart';
import '../models/item_servico.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'registra_servico.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE servicos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_cliente TEXT,
        data_servico TEXT,
        descricao_servico TEXT,
        valor_total REAL
      )
      '''
    );
    await db.execute(
      '''
      CREATE TABLE itens_servico(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        servico_id INTEGER,
        quantidade INTEGER,
        valor_unitario REAL,
        FOREIGN KEY (servico_id) REFERENCES servicos (id) ON DELETE CASCADE
      )
      '''
    );
  }

  Future<int> insertServico(Servico servico) async {
    Database db = await database;
    return await db.insert('servicos', servico.toMap());
  }

  Future<int> insertItemServico(ItemServico itemServico) async {
    Database db = await database;
    return await db.insert('itens_servico', itemServico.toMap());
  }

  Future<List<Servico>> getServicos() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('servicos', orderBy: 'data_servico DESC');
    return List.generate(maps.length, (i) {
      return Servico.fromMap(maps[i]);
    });
  }

  Future<List<ItemServico>> getItensServico(int servicoId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'itens_servico',
      where: 'servico_id = ?',
      whereArgs: [servicoId],
    );
    return List.generate(maps.length, (i) {
      return ItemServico.fromMap(maps[i]);
    });
  }

  Future<int> updateServico(Servico servico) async {
    Database db = await database;
    return await db.update(
      'servicos',
      servico.toMap(),
      where: 'id = ?',
      whereArgs: [servico.id],
    );
  }

  Future<int> deleteServico(int id) async {
    Database db = await database;
    return await db.delete(
      'servicos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItemServico(int id) async {
    Database db = await database;
    return await db.delete(
      'itens_servico',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

