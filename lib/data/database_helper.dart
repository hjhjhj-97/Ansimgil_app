import 'package:ansimgil_app/data/emergency_contact.dart';
import 'package:ansimgil_app/data/favorite.dart';
import 'package:ansimgil_app/data/search_history.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
     CREATE TABLE "emergency_contacts" (
      "id"	INTEGER NOT NULL,
      "name"	TEXT NOT NULL,
      "phone_number"	TEXT NOT NULL,
      "is_primary"	INTEGER NOT NULL DEFAULT 0,
      "message_template"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    )
    ''');

    await db.execute('''
     CREATE TABLE "favorites" (
      "id"	INTEGER NOT NULL,
      "start_name"	TEXT NOT NULL,
      "start_latitude"	REAL NOT NULL,
      "start_longitude"	REAL NOT NULL,
      "end_name"	TEXT NOT NULL,
      "end_latitude"	REAL NOT NULL,
      "end_longitude"	REAL NOT NULL,
      "created_at"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    )
    ''');

    await db.execute('''
     CREATE TABLE "search_history" (
      "id"	INTEGER NOT NULL,
      "start_name"	TEXT NOT NULL,
      "start_latitude"	REAL NOT NULL,
      "start_longitude"	REAL NOT NULL,
      "end_name"	TEXT NOT NULL,
      "end_latitude"	REAL NOT NULL,
      "end_longitude"	REAL NOT NULL,
      "created_at"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    )
    ''');
  }

  Future<int> insertEmergencyContact(EmergencyContact emergency) async {
    Database db = await instance.database;
    return await db.transaction((txn) async {
      if (emergency.isPrimary) {
        await txn.update(
          'emergency_contacts',
          {'is_primary': 0},
          where: 'is_primary = ?',
          whereArgs: [1],
        );
      }
      return await txn.insert('emergency_contacts', emergency.toMap());
    });
  }


  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
        'emergency_contacts',
        orderBy: 'is_primary DESC, id ASC'
    );
    return List.generate(maps.length, (i) {
      return EmergencyContact.fromMap(maps[i]);
    });
  }

  Future<EmergencyContact?> getEmergencyContactById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
        'emergency_contacts',
        where: 'id=?',
        whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return EmergencyContact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEmergencyContact(EmergencyContact emergency) async {
    Database db = await instance.database;
    return await db.update(
      'emergency_contacts',
      emergency.toMap(),
      where: 'id=?',
      whereArgs: [emergency.id],
    );
  }

  Future<int> updatePrimaryContact(int newPrimaryId) async {
    Database db = await instance.database;
    return await db.transaction((txn) async {
      await txn.update(
        'emergency_contacts',
        {'is_primary': 0},
        where: 'is_primary = ?',
        whereArgs: [1],
      );
      return await txn.update(
        'emergency_contacts',
        {'is_primary': 1},
        where: 'id = ?',
        whereArgs: [newPrimaryId],
      );
    });
  }

  Future<int> deleteEmergencyContact(int id) async {
    Database db = await instance.database;
    return await db.delete(
        'emergency_contacts',
        where: 'id=?',
        whereArgs: [id],
    );
  }

  Future<int> insertFavorite(Favorite favorite) async {
    Database db = await instance.database;
    return await db.insert('favorites', favorite.toMap());
  }

  Future<List<Favorite>> getAllFavorites() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Favorite.fromMap(maps[i]);
    });
  }

  Future<Favorite?> getFavoriteById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Favorite.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFavorite(Favorite favorite) async {
    Database db = await instance.database;
    return await db.update(
      'favorites',
      favorite.toMap(),
      where: 'id = ?',
      whereArgs: [favorite.id],
    );
  }

  Future<int> deleteFavorite(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertSearchHistory(SearchHistory search) async {
    Database db = await instance.database;
    return await db.insert('search_history', search.toMap());
  }

  Future<List<SearchHistory>> getAllSearchHistorise() async {
    Database db = await instance.database;
    final List<Map<String,dynamic>> maps = await db.query('search_history');
    return List.generate(maps.length, (i) {
      return SearchHistory.fromMap(maps[i]);
    });
  }

  Future<SearchHistory?> getSearchHistoryById(int id) async {
    Database db = await instance.database;
    List<Map<String,dynamic>> maps = await db.query(
        'search_history',
        where: 'id=?',
        whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SearchHistory.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSearchHistory(SearchHistory search) async {
    Database db = await instance.database;
    return await db.update(
        'search_history',
        search.toMap(),
        where: 'id=?',
        whereArgs: [search.id],
    );
  }

  Future<void> addOrUpdateSearchHistory(SearchHistory search) async {
    Database db = await instance.database;
    List<Map<String,dynamic>> maps = await db.query(
        'search_history',
        where: 'start_name = ? AND end_name = ?',
        whereArgs: [search.startName, search.endName],
    );
    if (maps.isNotEmpty) {
      int existingId = maps.first['id'];
      await db.update(
          'search_history',
          {'created_at': DateTime.now().toIso8601String()},
          where: 'id=?',
          whereArgs: [existingId],
      );
      print('기존 검색 기록 시간 업데이트 ID: ${existingId}');
    } else {
      int newId = await db.insert('search_history', search.toMap());
      print('새로운 검색 기록 저장 ID: ${newId}');
    }
  }

  Future<int> deleteSearchHistory(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'search_history',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}