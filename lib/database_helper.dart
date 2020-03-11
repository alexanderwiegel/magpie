import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'sortMode.dart';
import 'widgets/nest.dart';
import 'widgets/nestItem.dart';

class DatabaseHelper {
  static final _databaseName = "MagpiePrototype24.db";
  static final _databaseVersion = 4;

  static final nests = 'Nester';
  static final columnId = 'id';
  static final columnAlbumCover = 'albumCover';
  static final columnName = 'name';
  static final columnNote = 'note';
  static final totalWorth = 'totalWorth';
  static final columnFavored = 'favored';
  static final columnDate = 'date';

  static final nestItems = 'NestItems';
  static final id = 'id';
  static final nestId = 'nestId';
  static final photo = 'photo';
  static final name = 'name';
  static final note = 'note';
  static final worth = 'worth';
  static final favored = 'favored';
  static final date = 'date';

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
            $columnNote TEXT,
            $totalWorth INTEGER,
            $columnFavored BOOL,
            $columnDate INTEGER
          )
          ''');
    await db.execute('''
          CREATE TABLE $nestItems (
            $id INTEGER PRIMARY KEY,
            $nestId INTEGER,
            $photo BLOB,
            $name TEXT NOT NULL,
            $note TEXT,
            $worth INTEGER,
            $favored BOOL,
            $date INTEGER
          )
          ''');
  }

  Future<List<Nest>> getNests(SortMode sortMode, bool onlyFavored) async {
    var dbClient = await database;

    var sortModeSql;
    switch (sortMode) {
      case SortMode.SortById:
        sortModeSql = columnId;
        break;
      case SortMode.SortByName:
        sortModeSql = columnName;
        break;
      case SortMode.SortByWorth:
        sortModeSql = totalWorth;
        break;
      case SortMode.SortByFavored:
        sortModeSql = columnFavored;
        break;
      case SortMode.SortByDate:
        sortModeSql = columnDate;
    }

    String sql;
    if (!onlyFavored) {
      sql = "SELECT * FROM $nests ORDER BY $sortModeSql";
    } else {
      sql =
          "SELECT * FROM $nests WHERE $columnFavored = -1 ORDER BY $sortModeSql";
      // "'SELECT * FROM $nests WHERE $columnFavored = ? ORDER BY $sortModeSql', [1]";
      //TODO: Parametrisierung funktioniert nicht, Lösung finden
    }
    var result = await dbClient.rawQuery(sql);
    if (result.length == 0) return null;
    List<Nest> list = result.map((item) {
      return Nest.fromMap(item);
    }).toList();
    return list;
  }

  Future<List<NestItem>> getNestItems(
      int givenID, SortMode sortMode, bool onlyFavored) async {
    var dbClient = await database;

    var sortModeSql;
    switch (sortMode) {
      case SortMode.SortById:
        sortModeSql = id;
        break;
      case SortMode.SortByName:
        sortModeSql = name;
        break;
      case SortMode.SortByWorth:
        sortModeSql = worth;
        break;
      case SortMode.SortByFavored:
        sortModeSql = favored;
        break;
      case SortMode.SortByDate:
        sortModeSql = date;
    }

    String sql;
    if (!onlyFavored) {
      sql =
          "SELECT * FROM $nestItems WHERE $nestId = $givenID ORDER BY $sortModeSql";
      //TODO: Parametrisierung funktioniert nicht, Lösung finden
    } else {
      sql =
          "SELECT * FROM $nestItems WHERE $nestId = $givenID AND $favored = -1 ORDER BY $sortModeSql";
      //TODO: Parametrisierung funktioniert nicht, Lösung finden
    }
    var result = await dbClient.rawQuery(sql);
    if (result.length == 0) return null;
    List<NestItem> list = result.map((item) {
      return NestItem.fromMap(item);
    }).toList();
    return list;
  }

  Future<Nest> getNest(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(nests);
    return Nest.fromMap(maps[id]);
    /*
    return Nest(
      albumCover: maps[id]['albumCover'],
      name: maps[id]['name'],
      note: maps[id]['note'],
      totalWorth: maps[id]['totalWorth'],
    );
     */
  }

  Future<NestItem> getNestItem(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(nestItems);

    return NestItem.fromMap(maps[id]);
    /*
    return NestItem(
      nestId: maps[id]['nestId'],
      photo: maps[id]['photo'],
      name: maps[id]['name'],
      note: maps[id]['note'],
      worth: maps[id]['worth'],
    );

     */
  }

  Future<void> vacuum() async {
    final Database db = await database;
    await db.execute("VACUUM");
  }

  Future<int> getTotalWorth(Nest nest) async {
    final Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM($worth) FROM $nestItems WHERE $nestId = ?', [nest.id]));
  }

  Future<int> getNestCount() async {
    final Database db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $nests'));
  }

  Future<int> getNestItemCount(int id) async {
    final Database db = await database;
    return Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM $nestItems WHERE $nestId = ?', [id]));
  }

  Future<int> insert(Nest nest) async {
    Database db = await instance.database;

    File albumCover = nest.albumCover;
    int date = nest.date.millisecondsSinceEpoch;

    return await db.rawInsert(
        'INSERT INTO $nests'
        '($columnAlbumCover, $columnName, $columnNote, $totalWorth, $columnFavored, $columnDate)'
        'VALUES(?,?,?,?,?,?)',
        ['LOAD_FILE($albumCover)', nest.name, nest.note, 0, 0, date]);

    //return await db.insert(nests, nest.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertItem(NestItem nestItem) async {
    Database db = await instance.database;
    File pic = nestItem.photo;
    int date = nestItem.date.millisecondsSinceEpoch;

    return await db.rawInsert(
        'INSERT INTO $nestItems'
        '($nestId, $photo, $name, $note, $worth, $favored, $date)'
        'VALUES(?,?,?,?,?,?,?)',
        [
          nestItem.nestId,
          'LOAD_FILE($pic)',
          nestItem.name,
          nestItem.note,
          nestItem.worth,
          0,
          date
        ]);
    //return await db.insert(nests, nest.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Nest nest) async {
    Database db = await instance.database;
    File albumCover = nest.albumCover;
    int fav = nest.favored ? -1 : 0;
    int date = nest.date.millisecondsSinceEpoch;

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
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnNote = ?'
        ' WHERE $columnId = ?',
        [nest.note, nest.id]);
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $totalWorth = ?'
        ' WHERE $columnId = ?',
        [nest.totalWorth, nest.id]);
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnFavored = ?'
        ' WHERE $columnId = ?',
        [fav, nest.id]);
    return await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnDate = ?'
        ' WHERE $columnId = ?',
        [date, nest.id]);
    //    .update(nests, nest.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateItem(NestItem nestItem) async {
    Database db = await instance.database;
    File pic = nestItem.photo;
    int fav = nestItem.favored ? -1 : 0;
    int date = nestItem.date.millisecondsSinceEpoch;

    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $photo = ?'
        ' WHERE $id = ?',
        ['LOAD_FILE($pic)', nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $name = ?'
        ' WHERE $id = ?',
        [nestItem.name, nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $note = ?'
        ' WHERE $id = ?',
        [nestItem.note, nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $worth = ?'
        ' WHERE $id = ?',
        [nestItem.worth, nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $favored = ?'
        ' WHERE $id = ?',
        [fav, nestItem.id]);
    return await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $date = ?'
        ' WHERE $id = ?',
        [date, nestItem.id]);
    //    .update(nests, nest.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteNest(int id) async {
    Database db = await instance.database;
    await db.delete(nests, where: '$columnId = ?', whereArgs: [id]);
    return db.delete(nestItems, where: '$nestId = ?', whereArgs: [id]);
  }

  Future<int> deleteNestItem(int itemId) async {
    Database db = await instance.database;
    return await db.delete(nestItems, where: '$id = ?', whereArgs: [itemId]);
  }

  Future<int> clear() async {
    Database db = await instance.database;
    return await db.delete(nests);
  }
}
