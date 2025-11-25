// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class CycleCountDatabase{
//   static final CycleCountDatabase _instance = CycleCountDatabase._internal();

//   factory CycleCountDatabase() {
//     return _instance;
//   }

//   CycleCountDatabase._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'cyclecount.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     // Create CycleCountHeader table
//     await db.execute('''
//       CREATE TABLE cycle_count_header(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         portfolio TEXT NOT NULL,
//         timestamp TEXT NOT NULL,
//         userId TEXT NOT NULL,
//         totalItems INTEGER DEFAULT 0,
//         scannedItems INTEGER DEFAULT 0
//       )
//     ''');

//     // Create CycleCountDetail table
//     await db.execute('''
//       CREATE TABLE cycle_count_details(
//         detailId INTEGER PRIMARY KEY AUTOINCREMENT,
//         headerId INTEGER NOT NULL,
//         barcode TEXT NOT NULL,
//         itemCode TEXT NOT NULL,
//         description TEXT NOT NULL,
//         quantity INTEGER NOT NULL DEFAULT 0,
//         notes TEXT,
//         picture TEXT,
//         timestamp TEXT NOT NULL,
//         isAutomatic INTEGER NOT NULL DEFAULT 1,
//         FOREIGN KEY(headerId) REFERENCES cycle_count_header(id)
//       )
//     ''');
//   }

//   // ============= Header Operations =============

//   /// Create a new cycle count session
//   Future<int> insertHeader(Map<String, dynamic> header) async {
//     final db = await database;
//     return await db.insert(
//       'cycle_count_header',
//       header,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   /// Get all cycle count headers
//   Future<List<Map<String, dynamic>>> getAllHeaders() async {
//     final db = await database;
//     return await db.query('cycle_count_header', orderBy: 'timestamp DESC');
//   }

//   /// Get a specific header by ID
//   Future<Map<String, dynamic>?> getHeader(int headerId) async {
//     final db = await database;
//     final result = await db.query(
//       'cycle_count_header',
//       where: 'id = ?',
//       whereArgs: [headerId],
//     );
//     return result.isNotEmpty ? result.first : null;
//   }

//   /// Update header (used for updating scanned count)
//   Future<int> updateHeader(int headerId, Map<String, dynamic> data) async {
//     final db = await database;
//     return await db.update(
//       'cycle_count_header',
//       data,
//       where: 'id = ?',
//       whereArgs: [headerId],
//     );
//   }

//   /// Delete a header and all its details
//   Future<int> deleteHeader(int headerId) async {
//     final db = await database;
//     // Delete all details first
//     await db.delete(
//       'cycle_count_details',
//       where: 'headerId = ?',
//       whereArgs: [headerId],
//     );
//     // Then delete header
//     return await db.delete(
//       'cycle_count_header',
//       where: 'id = ?',
//       whereArgs: [headerId],
//     );
//   }

//   // ============= Detail Operations =============

//   /// Insert a cycle count detail
//   Future<int> insertDetail(Map<String, dynamic> detail) async {
//     final db = await database;
//     return await db.insert(
//       'cycle_count_details',
//       detail,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   /// Insert multiple details at once
//   Future<void> insertMultipleDetails(List<Map<String, dynamic>> details) async {
//     final db = await database;
//     final batch = db.batch();

//     for (var detail in details) {
//       batch.insert(
//         'cycle_count_details',
//         detail,
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     }

//     await batch.commit();
//   }

//   /// Get all details for a specific header
//   Future<List<Map<String, dynamic>>> getDetailsByHeader(int headerId) async {
//     final db = await database;
//     return await db.query(
//       'cycle_count_details',
//       where: 'headerId = ?',
//       whereArgs: [headerId],
//       orderBy: 'timestamp ASC',
//     );
//   }

//   /// Search detail by barcode within a header
//   Future<Map<String, dynamic>?> getDetailByBarcode(
//       int headerId, String barcode) async {
//     final db = await database;
//     final result = await db.query(
//       'cycle_count_details',
//       where: 'headerId = ? AND barcode = ?',
//       whereArgs: [headerId, barcode],
//     );
//     return result.isNotEmpty ? result.first : null;
//   }

//   /// Search details by item code within a header
//   Future<List<Map<String, dynamic>>> getDetailsByItemCode(
//       int headerId, String itemCode) async {
//     final db = await database;
//     return await db.query(
//       'cycle_count_details',
//       where: 'headerId = ? AND itemCode LIKE ?',
//       whereArgs: [headerId, '%$itemCode%'],
//     );
//   }

//   /// Update a detail (mainly for quantity changes)
//   Future<int> updateDetail(int detailId, Map<String, dynamic> data) async {
//     final db = await database;
//     return await db.update(
//       'cycle_count_details',
//       data,
//       where: 'detailId = ?',
//       whereArgs: [detailId],
//     );
//   }

//   /// Delete a detail
//   Future<int> deleteDetail(int detailId) async {
//     final db = await database;
//     return await db.delete(
//       'cycle_count_details',
//       where: 'detailId = ?',
//       whereArgs: [detailId],
//     );
//   }

//   /// Get count of scanned items for a header
//   Future<int> getScannedCount(int headerId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) as count FROM cycle_count_details WHERE headerId = ?',
//       [headerId],
//     );
//     return result.isNotEmpty
//         ? (result.first['count'] as int?) ?? 0
//         : 0;
//   }

//   /// Get summary statistics for a header
//   Future<Map<String, int>> getHeaderSummary(int headerId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       '''SELECT 
//         COUNT(DISTINCT barcode) as uniqueBarcodes,
//         SUM(quantity) as totalQuantity,
//         COUNT(*) as totalLines
//         FROM cycle_count_details 
//         WHERE headerId = ?''',
//       [headerId],
//     );

//     if (result.isNotEmpty) {
//       return {
//         'uniqueBarcodes': (result.first['uniqueBarcodes'] as int?) ?? 0,
//         'totalQuantity': (result.first['totalQuantity'] as int?) ?? 0,
//         'totalLines': (result.first['totalLines'] as int?) ?? 0,
//       };
//     }

//     return {'uniqueBarcodes': 0, 'totalQuantity': 0, 'totalLines': 0};
//   }

//   /// Clear all data (for testing)
//   Future<void> clearAllData() async {
//     final db = await database;
//     await db.delete('cycle_count_details');
//     await db.delete('cycle_count_header');
//   }

//   /// Close database
//   Future<void> close() async {
//     final db = await database;
//     await db.close();
//   }
// }