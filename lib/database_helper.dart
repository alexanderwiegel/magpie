import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/nest.dart';

class DatabaseHelper {
  static final _databaseName = "Magpie2.db";
  static final _databaseVersion = 4;

  static final nests = 'Nester';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnNote = 'note';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $nests (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnNote TEXT
          )
          ''');
  }

  Future<List<Nest>> getNests() async {
    var dbClient = await database;
    String sql;
    sql = "SELECT * FROM $nests";

    var result = await dbClient.rawQuery(sql);
    if (result.length == 0) return null;

    List<Nest> list = result.map((item) {
      return Nest.fromMap(item);
    }).toList();

    print(result);
    return list;
  }

  Future<Nest> getNest(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(nests);

    return Nest(
        name: maps[id]['name'],
        note: maps[id]['note'],
    );
  }

  Future<int> getNestCount() async {
    final Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $nests'));
  }

  Future<int> insert(Nest nest) async {
    Database db = await instance.database;
    return await db.insert(nests, nest.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Nest nest) async {
    Database db = await instance.database;
    int id = nest.id;
    print("ID während des Updates $id");
    return await db.update(nests, nest.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(nests, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> clear() async {
    Database db = await instance.database;
    return await db.delete(nests);
  }
}
