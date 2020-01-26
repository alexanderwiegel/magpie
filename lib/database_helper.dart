import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/nest.dart';

class DatabaseHelper {
  static final _databaseName = "Magpie10.db";
  static final _databaseVersion = 4;

  static final nests = 'Nester';

  static final columnId = 'id';
  static final columnAlbumCover = 'albumCover';
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
            $columnAlbumCover BLOB,
            $columnName TEXT NOT NULL,
            $columnNote TEXT
          )
          ''');
  }

  Future<List<Nest>> getNests() async {
    var dbClient = await database;
    var result = await dbClient.rawQuery("SELECT * FROM $nests");
    if (result.length == 0) return null;
    List<Nest> list = result.map((item) {
      return Nest.fromMap(item);
    }).toList();
    return list;
  }

  Future<Nest> getNest(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(nests);

    return Nest(
      albumCover: maps[id]['albumCover'],
      name: maps[id]['name'],
      note: maps[id]['note'],
    );
  }

  Future<int> getNestCount() async {
    final Database db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $nests'));
  }

  Future<int> insert(Nest nest) async {
    Database db = await instance.database;

    File albumCover = nest.albumCover;
    return await db.rawInsert(
        'INSERT INTO $nests'
        '($columnAlbumCover, $columnName, $columnNote)'
        'VALUES(?,?,?)',
        ['LOAD_FILE($albumCover)', nest.name, nest.note]);

    //return await db.insert(nests, nest.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Nest nest) async {
    Database db = await instance.database;
    File albumCover = nest.albumCover;
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnAlbumCover = ?'
        ' WHERE $columnId = ?',
        ['LOAD_FILE($albumCover)', nest.id]);
    await db.rawUpdate(
        'UPDATE $nests'
            ' SET $columnName = ?'
            ' WHERE $columnId = ?',
        [nest.name, nest.id]);
    return await db.rawUpdate(
        'UPDATE $nests'
            ' SET $columnNote = ?'
            ' WHERE $columnId = ?',
        [nest.note, nest.id]);
    //    .update(nests, nest.toMap(), where: '$columnId = ?', whereArgs: [id]);
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
