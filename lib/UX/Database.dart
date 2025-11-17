import 'package:flutter/cupertino.dart';
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
    var myDb = await openDatabase(path, version: 2, onCreate: _onCreateDb, onUpgrade: _onUpgradeDb);
    return myDb;
  }

  _onCreateDb(Database db, int newVersion) async {
    await db.execute(createPortfolioTable);
    await db.execute(createCycleCountHeader);
    await db.execute(createCycleCountDetails);
    // await db.execute(createPropertyImagesTable);
    // await db.execute(createUserInteractionsTable);
  }

  _onUpgradeDb(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS Portfolio");
    await db.execute("DROP TABLE IF EXISTS CycleCountHeader");
    await db.execute("DROP TABLE IF EXISTS CycleCountDetails");
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
}
