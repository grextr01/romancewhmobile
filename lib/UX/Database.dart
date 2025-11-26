import 'package:flutter/cupertino.dart';
import 'package:romancewhs/Models/portfolio.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'DatabaseUX/queries.dart';

class dbConn {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  initDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    //await CacheData.cacheInitialization();
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String path = join(appDirectory.path, 'Data.db');
    var myDb = await openDatabase(path, version: 5, onCreate: _onCreateDb, onUpgrade: _onUpgradeDb);
    return myDb;
  }

  _onCreateDb(Database db, int newVersion) async {
    await db.execute(createPortfolioTable);
     await db.execute(createCycleCountHeader);
    await db.execute(createCycleCountDetails);
    // await _db.execute(createPropertyImagesTable);
    // await _db.execute(createUserInteractionsTable);
  }

  _onUpgradeDb(Database db, int oldVersion, int newVersion) async {
    //await db.execute("DROP TABLE IF EXISTS Portfolio");
     //await db.execute("DROP TABLE IF EXISTS CycleCountHeader");
    // await db.execute("DROP TABLE IF EXISTS CycleCountDetails");
    _onCreateDb(db, newVersion);
  }

  // Future<int> createUser(User user) async{
  //   var dbClient = await db;
  //   int result = await dbClient.insert("users", user.toMap());
  //   return result;
  // }

  Future<void> executeQuery(String sql) async {
    var dbClient = await db;
    await dbClient.execute(sql);
  }

  Future<int> addToDb(dynamic obj, String table) async {
    var dbClient = await db;
    int result = await dbClient.insert(table, obj.toMap());
    return result;
  }

  Future<List> dbToList(String tableName) async {
    var dbClient = await db;
    var sql = 'select * from $tableName;';
    List result = await dbClient.rawQuery(sql);
    return result.toList();
  }

  Future<List> getUsers() async {
    var dbClient = await db;
    var sql = 'select * from users;';
    List result = await dbClient.rawQuery(sql);
    return result.toList();
  }

  Future<List> queryToList(String query) async {
    var dbClient = await db;
    List result = await dbClient.rawQuery(query);
    return result.toList();
  }

  Future<List<String>> StringList(String item) async {
    var dbClient = await db;
    String query = 'select description from $item';
    List result = await dbClient.rawQuery(query);
    List<String> returnList = [];
    result.forEach((element) {
      returnList.add(element['description']);
    });
    return returnList.toList();
  }

  Future<int> insertPortfolio(Portfolio portfolio) async {
    final _db = await db;
    return await _db.insert(
      'portfolio',
      portfolio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple portfolio items
  Future<void> insertMultiplePortfolios(List<Portfolio> portfolios) async {
    final _db = await db;
    final batch = _db.batch();
    
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
    final _db = await db;
    final List<Map<String, dynamic>> maps = await _db.query('portfolio');
    return List.generate(maps.length, (i) => Portfolio.fromMap(maps[i]));
  }

  // Search by barcode
  Future<List<Portfolio>> searchByBarcode(String barcode) async {
    final _db = await db;
    final List<Map<String, dynamic>> maps = await _db.query(
      'portfolio',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    return List.generate(maps.length, (i) => Portfolio.fromMap(maps[i]));
  }

  // Search by item code
  Future<List<Portfolio>> searchByItemCode(String itemCode) async {
    final _db = await db;
    final List<Map<String, dynamic>> maps = await _db.query(
      'portfolio',
      where: 'itemCode = ?',
      whereArgs: [itemCode],
    );
    return List.generate(maps.length, (i) => Portfolio.fromMap(maps[i]));
  }

  // Delete all portfolio items
  Future<int> deleteAllPortfolios() async {
    final _db = await db;
    return await _db.delete('portfolio');
  }

  // Delete by id
  Future<int> deletePortfolio(int id) async {
    final _db = await db;
  return await _db.delete(
      'portfolio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update portfolio
  Future<int> updatePortfolio(Portfolio portfolio) async {
    final _db = await db;
    return await _db.update(
      'portfolio',
      portfolio.toMap(),
      where: 'id = ?',
      whereArgs: [portfolio.id],
    );
  }

  // Get count
  Future<int> getPortfolioCount() async {
    final _db = await db;
    final result = await _db.rawQuery('SELECT COUNT(*) as count FROM portfolio');
    return Sqflite.firstIntValue(result!) ?? 0;
  }


  Future<int> insertHeader(Map<String, dynamic> header) async {
    final _db = await db;
    return await _db.insert(
      'cycle_count_header',
      header,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all cycle count headers
  Future<List<Map<String, dynamic>>> getAllHeaders() async {
    final _db = await db;
    return await _db.query('cycle_count_header', orderBy: 'timestamp DESC');
  }

  /// Get a specific header by ID
  Future<Map<String, dynamic>?> getHeader(int headerId) async {
    final _db = await db;
    final result = await _db.query(
      'cycle_count_header',
      where: 'id = ?',
      whereArgs: [headerId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Update header (used for updating scanned count)
  Future<int> updateHeader(int headerId, Map<String, dynamic> data) async {
    final _db = await db;
    return await _db.update(
      'cycle_count_header',
      data,
      where: 'id = ?',
      whereArgs: [headerId],
    );
  }

  /// Delete a header and all its details
  Future<int> deleteHeader(int headerId) async {
    final _db = await db;
    // Delete all details first
    await _db.delete(
      'cycle_count_details',
      where: 'headerId = ?',
      whereArgs: [headerId],
    );
    // Then delete header
    return await _db.delete(
      'cycle_count_header',
      where: 'id = ?',
      whereArgs: [headerId],
    );
  }

  // ============= Detail Operations =============

  /// Insert a cycle count detail
  Future<int> insertDetail(Map<String, dynamic> detail) async {
    final _db = await db;
    return await _db.insert(
      'cycle_count_details',
      detail,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple details at once
  Future<void> insertMultipleDetails(List<Map<String, dynamic>> details) async {
    final _db = await db;
    final batch = _db.batch();

    for (var detail in details) {
      batch.insert(
        'cycle_count_details',
        detail,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  /// Get all details for a specific header
  Future<List<Map<String, dynamic>>> getDetailsByHeader(int headerId) async {
    final _db = await db;
    return await _db.query(
      'cycle_count_details',
      where: 'headerId = ?',
      whereArgs: [headerId],
      orderBy: 'timestamp ASC',
    );
  }

  /// Search detail by barcode within a header
  Future<Map<String, dynamic>?> getDetailByBarcode(
      int headerId, String barcode) async {
    final _db = await db;
    final result = await _db.query(
      'cycle_count_details',
      where: 'headerId = ? AND barcode = ?',
      whereArgs: [headerId, barcode],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Search details by item code within a header
  Future<List<Map<String, dynamic>>> getDetailsByItemCode(
      int headerId, String itemCode) async {
    final _db = await db;
    return await _db.query(
      'cycle_count_details',
      where: 'headerId = ? AND itemCode LIKE ?',
      whereArgs: [headerId, '%$itemCode%'],
    );
  }

  /// Update a detail (mainly for quantity changes)
  Future<int> updateDetail(int detailId, Map<String, dynamic> data) async {
    final _db = await db;
    return await _db.update(
      'cycle_count_details',
      data,
      where: 'detailId = ?',
      whereArgs: [detailId],
    );
  }

  /// Delete a detail
  Future<int> deleteDetail(int detailId) async {
    final _db = await db;
    return await _db.delete(
      'cycle_count_details',
      where: 'detailId = ?',
      whereArgs: [detailId],
    );
  }

  /// Get count of scanned items for a header
  Future<int> getScannedCount(int headerId) async {
    final _db = await db;
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM cycle_count_details WHERE headerId = ?',
      [headerId],
    );
    return result.isNotEmpty
        ? (result.first['count'] as int?) ?? 0
        : 0;
  }

  /// Get summary statistics for a header
  Future<Map<String, int>> getHeaderSummary(int headerId) async {
    final _db = await db;
    final result = await _db.rawQuery(
      '''SELECT 
        COUNT(DISTINCT barcode) as uniqueBarcodes,
        SUM(quantity) as totalQuantity,
        COUNT(*) as totalLines
        FROM cycle_count_details 
        WHERE headerId = ?''',
      [headerId],
    );

    if (result.isNotEmpty) {
      return {
        'uniqueBarcodes': (result.first['uniqueBarcodes'] as int?) ?? 0,
        'totalQuantity': (result.first['totalQuantity'] as int?) ?? 0,
        'totalLines': (result.first['totalLines'] as int?) ?? 0,
      };
    }

    return {'uniqueBarcodes': 0, 'totalQuantity': 0, 'totalLines': 0};
  }

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    final _db = await db;
    await _db.delete('cycle_count_details');
    await _db.delete('cycle_count_header');
  }

  /// Close database
  Future<void> close() async {
    final _db = await db;
    await _db.close();
  }
}
