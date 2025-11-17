import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:romancewhs/Models/portfolio.dart';
class PortfolioDatabase {
  static final PortfolioDatabase _instance = PortfolioDatabase._internal();

  factory PortfolioDatabase() {
    return _instance;
  }

  PortfolioDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'portfolio.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE portfolio(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT NOT NULL,
        itemCode TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT
      )
    ''');
  }

  // Insert a single portfolio item
  Future<int> insertPortfolio(Portfolio portfolio) async {
    final db = await database;
    return await db.insert(
      'portfolio',
      portfolio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple portfolio items
  Future<void> insertMultiplePortfolios(List<Portfolio> portfolios) async {
    final db = await database;
    final batch = db.batch();
    
    for (var portfolio in portfolios) {
      batch.insert(
        'portfolio',
        portfolio.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }

  // Get all portfolio items
  Future<List<Portfolio>> getAllPortfolios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('portfolio');
    return List.generate(maps.length, (i) => Portfolio.fromMap(maps[i]));
  }

  // Search by barcode
  Future<List<Portfolio>> searchByBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'portfolio',
      where: 'barcode LIKE ?',
      whereArgs: ['%$barcode%'],
    );
    return List.generate(maps.length, (i) => Portfolio.fromMap(maps[i]));
  }

  // Search by item code
  Future<List<Portfolio>> searchByItemCode(String itemCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'portfolio',
      where: 'itemCode LIKE ?',
      whereArgs: ['%$itemCode%'],
    );
    return List.generate(maps.length, (i) => Portfolio.fromMap(maps[i]));
  }

  // Delete all portfolio items
  Future<int> deleteAllPortfolios() async {
    final db = await database;
    return await db.delete('portfolio');
  }

  // Delete by id
  Future<int> deletePortfolio(int id) async {
    final db = await database;
    return await db.delete(
      'portfolio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update portfolio
  Future<int> updatePortfolio(Portfolio portfolio) async {
    final db = await database;
    return await db.update(
      'portfolio',
      portfolio.toMap(),
      where: 'id = ?',
      whereArgs: [portfolio.id],
    );
  }

  // Get count
  Future<int> getPortfolioCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM portfolio');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}