import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'sortMode.dart';
import 'widgets/nest.dart';
import 'widgets/nestItem.dart';

class DatabaseHelper {
  static final _databaseName = "MagpiePrototype34.db";
  static final _databaseVersion = 6;

  static final home = 'Home';
  static final homeSort = 'homeSort';
  static final homeAsc = 'homeAsc';
  static final homeOnlyFavored = 'homeOnlyFavored';

  static final nests = 'Nester';
  static final columnId = 'id';
  static final columnUserId = 'userId';
  static final columnAlbumCover = 'albumCover';
  static final columnName = 'name';
  static final columnNote = 'note';
  static final columnTotalWorth = 'totalWorth';
  static final columnFavored = 'favored';
  static final columnDate = 'date';
  static final columnSortMode = 'sortMode';
  static final columnAsc = 'asc';
  static final columnOnlyFavored = 'onlyFavored';

  static final nestItems = 'NestItems';
  static final columnNestId = 'nestId';
  static final columnPhoto = 'photo';
  static final columnWorth = 'worth';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $nests (
            $columnId INTEGER PRIMARY KEY,
            $columnUserId TEXT NOT NULL,
            $columnAlbumCover BLOB,
            $columnName TEXT NOT NULL,
            $columnNote TEXT,
            $columnTotalWorth INTEGER,
            $columnFavored BOOL,
            $columnDate INTEGER,
            $columnSortMode TEXT,
            $columnAsc BOOL,
            $columnOnlyFavored BOOL
          )
          ''');
    await db.execute('''
          CREATE TABLE $nestItems (
            $columnId INTEGER PRIMARY KEY,
            $columnNestId INTEGER,
            $columnPhoto BLOB,
            $columnName TEXT NOT NULL,
            $columnNote TEXT,
            $columnWorth INTEGER,
            $columnFavored BOOL,
            $columnDate INTEGER
          )
          ''');
    await db.execute('''
          CREATE TABLE $home (
            $homeAsc BOOL,
            $homeOnlyFavored BOOL,
            $homeSort TEXT
          )
          ''');
    Map<String, dynamic> homeMap = {
      homeAsc: 1,
      homeOnlyFavored: 0,
      homeSort: SortMode.SortByDate.toString(),
    };
    await db.insert(home, homeMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Nest>> getNests(String userId) async {
    var dbClient = await database;
    var homeStatus = await dbClient.rawQuery("SELECT * FROM $home");
    bool asc = homeStatus.first.values.elementAt(0) == 1 ? true : false;
    bool onlyFav = homeStatus.first.values.elementAt(1) == 1 ? true : false;
    String sortModeAsString = homeStatus.first.values.elementAt(2);
    SortMode sortMode =
        SortMode.values.firstWhere((e) => e.toString() == sortModeAsString);

    var sortModeSql;
    switch (sortMode) {
      case SortMode.SortByName:
        sortModeSql = columnName;
        break;
      case SortMode.SortByWorth:
        sortModeSql = columnTotalWorth;
        break;
      case SortMode.SortByFavored:
        sortModeSql = columnFavored;
        break;
      case SortMode.SortByDate:
        sortModeSql = columnDate;
    }

    String sql;
    if (!onlyFav) {
      sql =
          "SELECT * FROM $nests WHERE $columnUserId = '$userId' ORDER BY $sortModeSql";
      //TODO: Parametrisierung funktioniert nicht, Lösung finden (SQL Injection)
    } else {
      sql =
          "SELECT * FROM $nests WHERE $columnFavored = -1 AND $columnUserId = '$userId' ORDER BY $sortModeSql";
      // "'SELECT * FROM $nests WHERE $columnFavored = ? ORDER BY $sortModeSql', [1]";
      //TODO: Parametrisierung funktioniert nicht, Lösung finden (SQL Injection)
    }
    if (!asc) {
      sql += " DESC";
    }
    var result = await dbClient.rawQuery(sql);
    print(result);
    if (result.length == 0) return null;
    List<Nest> list = result.map((item) {
      return Nest.fromMap(item);
    }).toList();
    return list;
  }

  Future<List<NestItem>> getNestItems(Nest nest) async {
    var dbClient = await database;

    var sortModeSql;
    switch (nest.sortMode) {
      case SortMode.SortByName:
        sortModeSql = columnName;
        break;
      case SortMode.SortByWorth:
        sortModeSql = columnWorth;
        break;
      case SortMode.SortByFavored:
        sortModeSql = columnFavored;
        break;
      case SortMode.SortByDate:
        sortModeSql = columnDate;
    }

    String sql;
    if (!nest.onlyFavored) {
      sql =
          "SELECT * FROM $nestItems WHERE $columnNestId = ${nest.id} ORDER BY $sortModeSql";
      //TODO: Parametrisierung funktioniert nicht, Lösung finden (SQL Injection)
    } else {
      sql =
          "SELECT * FROM $nestItems WHERE $columnNestId = ${nest.id} AND $columnFavored = -1 ORDER BY $sortModeSql";
      //TODO: Parametrisierung funktioniert nicht, Lösung finden (SQL Injection)
    }
    if (!nest.asc) {
      sql += " DESC";
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
  }

  Future<NestItem> getNestItem(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(nestItems);
    return NestItem.fromMap(maps[id]);
  }

  // not sure if this actually works
  Future<void> vacuum() async {
    final Database db = await database;
    await db.execute("VACUUM");
  }

  Future<int> getTotalWorth(Nest nest) async {
    final Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM($columnWorth) FROM $nestItems WHERE $columnNestId = ?',
        [nest.id]));
  }

  Future<int> getNestCount() async {
    final Database db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $nests'));
  }

  Future<int> getNestItemCount(int id) async {
    final Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $nestItems WHERE $columnNestId = ?', [id]));
  }

  Future<int> insert(Nest nest) async {
    Database db = await instance.database;

    File albumCover = nest.albumCover;
    int date = nest.date.millisecondsSinceEpoch;
    String sortModeAsString = nest.sortMode.toString();

    print("\n\n\n");
    print(nest.userId);
    print("\n\n\n");
    return await db.rawInsert(
        'INSERT INTO $nests'
        '($columnUserId, $columnAlbumCover, $columnName, $columnNote, $columnTotalWorth, $columnFavored, $columnDate, $columnSortMode, $columnAsc, $columnOnlyFavored)'
        'VALUES(?,?,?,?,?,?,?,?,?,?)',
        [
          nest.userId,
          'LOAD_FILE($albumCover)',
          nest.name,
          nest.note,
          0,
          0,
          date,
          sortModeAsString,
          1,
          0
        ]);

    //return await db.insert(nests, nest.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertItem(NestItem nestItem) async {
    Database db = await instance.database;
    File pic = nestItem.photo;
    int dateAsInt = nestItem.date.millisecondsSinceEpoch;

    return await db.rawInsert(
        'INSERT INTO $nestItems'
        '($columnNestId, $columnPhoto, $columnName, $columnNote, $columnWorth, $columnFavored, $columnDate)'
        'VALUES(?,?,?,?,?,?,?)',
        [
          nestItem.nestId,
          'LOAD_FILE($pic)',
          nestItem.name,
          nestItem.note,
          nestItem.worth,
          0,
          dateAsInt
        ]);
    //return await db.insert(nests, nest.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<dynamic>> getHome() async {
    var dbClient = await database;
    return await dbClient.rawQuery("SELECT * FROM $home");
  }

  Future<int> updateHome(bool asc, bool onlyFavored, SortMode sortMode) async {
    Database db = await instance.database;
    Map<String, dynamic> homeMap = {
      homeAsc: asc,
      homeOnlyFavored: onlyFavored,
      homeSort: sortMode.toString(),
    };
    return await db.update(home, homeMap);
  }

  Future<int> update(Nest nest) async {
    Database db = await instance.database;
    File albumCover = nest.albumCover;
    int fav = nest.favored ? -1 : 0;
    int date = nest.date.millisecondsSinceEpoch;
    int asc = nest.asc ? 1 : 0;
    String sortModeAsString = nest.sortMode.toString();
    int onlyFav = nest.onlyFavored ? 1 : 0;

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
        ' SET $columnTotalWorth = ?'
        ' WHERE $columnId = ?',
        [nest.totalWorth, nest.id]);
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnFavored = ?'
        ' WHERE $columnId = ?',
        [fav, nest.id]);
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnDate = ?'
        ' WHERE $columnId = ?',
        [date, nest.id]);
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnSortMode = ?'
        ' WHERE $columnId = ?',
        [sortModeAsString, nest.id]);
    await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnAsc = ?'
        ' WHERE $columnId = ?',
        [asc, nest.id]);
    return await db.rawUpdate(
        'UPDATE $nests'
        ' SET $columnOnlyFavored = ?'
        ' WHERE $columnId = ?',
        [onlyFav, nest.id]);
    //    .update(nests, nest.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateItem(NestItem nestItem) async {
    Database db = await instance.database;
    File pic = nestItem.photo;
    int fav = nestItem.favored ? -1 : 0;
    int date = nestItem.date.millisecondsSinceEpoch;

    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $columnPhoto = ?'
        ' WHERE $columnId = ?',
        ['LOAD_FILE($pic)', nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $columnName = ?'
        ' WHERE $columnId = ?',
        [nestItem.name, nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $columnNote = ?'
        ' WHERE $columnId = ?',
        [nestItem.note, nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $columnWorth = ?'
        ' WHERE $columnId = ?',
        [nestItem.worth, nestItem.id]);
    await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $columnFavored = ?'
        ' WHERE $columnId = ?',
        [fav, nestItem.id]);
    return await db.rawUpdate(
        'UPDATE $nestItems'
        ' SET $columnDate = ?'
        ' WHERE $columnId = ?',
        [date, nestItem.id]);
    //    .update(nests, nest.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteNest(int id) async {
    Database db = await instance.database;
    await db.delete(nests, where: '$columnId = ?', whereArgs: [id]);
    return db.delete(nestItems, where: '$columnNestId = ?', whereArgs: [id]);
  }

  Future<int> deleteNestItem(int itemId) async {
    Database db = await instance.database;
    return await db
        .delete(nestItems, where: '$columnId = ?', whereArgs: [itemId]);
  }

  Future<int> clear() async {
    Database db = await instance.database;
    return await db.delete(nests);
  }
}
