import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if(!kIsWeb) {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    }
    return Future.error("Database not supported on Web");
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'sensor_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sensors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            neck INTEGER,
            upperBack INTEGER,
            midBack INTEGER,
            lowerBack INTEGER,
            leftShoulder INTEGER,
            rightShoulder INTEGER,
            leftHip INTEGER,
            rightHip INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertSensorData(Map<String, int> data) async {
    try {
      final db = await database;
      await db.insert('sensors', data);
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
      } else {
        rethrow;
      }
    }
  }
}
