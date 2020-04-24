import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/nest.dart';
import '../models/nestItem.dart';
import '../sortMode.dart';

class DatabaseHelper {
  static final _databaseName = "MagpiePrototype40.db";
  static final _databaseVersion = 6;

  static final home = 'Home';
  static final homeUserId = 'homeUserId';
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
            $columnDate TEXT,
            $columnSortMode TEXT,
            $columnAsc BOOL,
            $columnOnlyFavored BOOL
          )
          ''');
    await db.execute('''
          CREATE TABLE $nestItems (
            $columnId INTEGER PRIMARY KEY,
            $columnUserId TEXT NOT NULL,
            $columnNestId INTEGER,
            $columnPhoto BLOB,
            $columnName TEXT NOT NULL,
            $columnNote TEXT,
            $columnWorth INTEGER,
            $columnFavored BOOL,
            $columnDate TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE $home (
            $homeAsc BOOL DEFAULT 1,
            $homeOnlyFavored BOOL DEFAULT 0,
            $homeSort TEXT,
            $homeUserId TEXT NOT NULL
          )
          ''');
  }

  String getColumnToSortBy(SortMode sortMode) {
    switch (sortMode) {
      case SortMode.SortByName:
        return columnName;
      case SortMode.SortByWorth:
        return columnTotalWorth;
      case SortMode.SortByFavored:
        return columnFavored;
      case SortMode.SortById:
        return columnId;
      default:
        return columnId;
    }
  }

  Future<List<Nest>> getNests(String userId) async {
    final Database db = await database;
    var homeStatus = await db.query(home, where: "$homeUserId = ?", whereArgs: [userId]);
    bool asc = homeStatus.first.values.elementAt(0) == 1 ? true : false;
    bool onlyFav = homeStatus.first.values.elementAt(1) == 1 ? true : false;
    String sortModeAsString = homeStatus.first.values.elementAt(2);
    SortMode sortMode =
        SortMode.values.firstWhere((e) => e.toString() == sortModeAsString);
    String sortModeSql = getColumnToSortBy(sortMode);
    String order = asc ? "ASC" : "DESC";
    String where = "$columnUserId = ?";
    List whereArgs = [userId];
    if (onlyFav) {
      where += " AND $columnFavored = ?";
      whereArgs.add(-1);
    }
    var result = await db.query(nests, where: where,
        whereArgs: whereArgs, orderBy: "$sortModeSql $order");
    if (result.length == 0) return null;
    List<Nest> list = result.map((item) {
      return Nest.fromMap(item);
    }).toList();
    return list;
  }

  Future<List<NestItem>> getNestItems(Nest nest) async {
    final Database db = await database;
    String sortModeSql = getColumnToSortBy(nest.sortMode);
    String order = nest.asc ? "ASC" : "DESC";
    String where = "$columnNestId = ?";
    List whereArgs = [nest.id];
    if (nest.onlyFavored) {
      where += " AND $columnFavored = ?";
      whereArgs.add(-1);
    }
    var result = await db.query(nestItems, where: where,
        whereArgs: whereArgs, orderBy: "$sortModeSql $order");
    if (result.length == 0) return null;
    List<NestItem> list = result.map((item) {
      return NestItem.fromMap(item);
    }).toList();
    return list;
  }

  Future<Nest> getNest(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM $nests WHERE $columnId = ?", [id]);
    return maps.length == 0 ? null : Nest.fromMap(maps[0]);
  }

  Future<NestItem> getNestItem(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(nestItems);
    return maps.length == 0 ? null : NestItem.fromMap(maps[id]);
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

  Future<int> getNestCount(String userId) async {
    final Database db = await database;
    var result = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM $nests WHERE $columnUserId = ?", [userId]));
    return result;
  }

  Future<int> getTotalItemCount(String userId) async {
    final Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $nestItems WHERE $columnUserId = ?', [userId]));
  }

  Future<int> getNestItemCount(int id) async {
    final Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $nestItems WHERE $columnNestId = ?', [id]));
  }

  Future getHistory(String userId) async {
    final Database db = await database;
    var result = await db.rawQuery("SELECT COUNT($columnId), $columnDate FROM $nestItems GROUP BY $columnDate");
    List dates = [];
    List count = [];
    //dates.add(DateTime.parse(result[0].values.elementAt(1)));
    //count.add(0);
    double sum = 0.0;
    for (int i = 0; i < result.length; i++) {
      sum += result[i].values.elementAt(0).toDouble();
      count.add(sum);
      dates.add(DateTime.parse(result[i].values.elementAt(1)));
    }
    return [count, dates];
  }

  Future getNestsWithItemCount(String userId) async {
    final Database db = await database;
    var result = await db.rawQuery(
        "SELECT $nests.$columnName, "
            "COUNT($nestItems.$columnId) FROM $nests INNER JOIN $nestItems "
            "ON $nests.$columnId=$nestItems.$columnNestId "
            "WHERE $nests.$columnUserId = ? "
            "GROUP BY $nestItems.$columnNestId ORDER BY COUNT($nestItems.$columnId) DESC", [userId]);
    List<String> list = [];
    for (int i = 0; i < result.length; i++) {
      list.add(result[i].values.toString());
    }
    return list;
  }

  Future<int> insert(Nest nest) async {
    Database db = await instance.database;
    return await db.insert(nests, nest.toMap(),
       conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertItem(NestItem nestItem) async {
    Database db = await instance.database;
    return await db.insert(nestItems, nestItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<dynamic>> getHome(String userId) async {
    Database db = await instance.database;
    return await db.query(home, where: "$homeUserId = ?", whereArgs: [userId]);
  }

  Future<int> insertHome(String userId) async {
    var dbClient = await database;
    Map<String, dynamic> homeMap = {
      homeAsc: 1,
      homeOnlyFavored: 0,
      homeSort: SortMode.SortById.toString(),
      homeUserId: userId
    };
    return await dbClient.insert(home, homeMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateHome(
      bool asc, bool onlyFavored, SortMode sortMode, String userId) async {
    Database db = await instance.database;
    Map<String, dynamic> homeMap = {
      homeAsc: asc ? 1 : 0,
      homeOnlyFavored: onlyFavored ? 1 : 0,
      homeSort: sortMode.toString(),
    };
    return await db.update(home, homeMap, where: "$homeUserId = ?",
        whereArgs: [userId]);
  }

  Future<int> update(Nest nest) async {
    Database db = await instance.database;
    return await db.update(nests, nest.toMap(), where: '$columnId = ?',
        whereArgs: [nest.id]);
  }

  Future<int> updateItem(NestItem nestItem) async {
    Database db = await instance.database;
    return await db.update(nestItems, nestItem.toMap(), where: '$columnId = ?',
        whereArgs: [nestItem.id]);
  }

  Future<int> deleteNest(int id) async {
    Database db = await instance.database;
    await db.delete(nests, where: '$columnId = ?', whereArgs: [id]);
    return await db.delete(nestItems, where: '$columnNestId = ?', whereArgs: [id]);
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
