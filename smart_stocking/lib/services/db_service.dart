import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/PostureAlert.dart';
import '../models/SensorData.dart';
import '../models/user.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _database;

  Future<Database> get database async {
    if(!kIsWeb) {
      _database ??= await _initDatabase();
      return _database!;
    }
    return Future.error("Database not supported on Web");
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'goodbone.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sensor_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        neck INTEGER,
        leftShoulder INTEGER,
        rightShoulder INTEGER,
        upperBack INTEGER,
        midBack INTEGER,
        lowerBack INTEGER,
        leftHip INTEGER,
        rightHip INTEGER,
        postureClass TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        gender TEXT,
        age INTEGER,
        heightCm REAL,
        chairType TEXT,
        chairHeight REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE posture_alert (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        alertType TEXT,
        message TEXT
      )
    ''');
  }

  // SensorData
  Future<int> insertSensorData(SensorData data) async {
    try {
      final db = await database;
      return await db.insert('sensor_data', data.toMap());
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
        return -1;
      } else {
        rethrow;
      }
    }
  }

  Future<List<SensorData>> getAllSensorData() async {
    try {
      final db = await database;
      final maps = await db.query('sensor_data', orderBy: 'timestamp DESC');
      return maps.map((e) => SensorData.fromMap(e)).toList();
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
        return [];
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteAllSensorData() async {
    try {
      final db = await database;
      await db.delete('sensor_data');
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
      } else {
        rethrow;
      }
    }
  }

  // UserProfile
  Future<int> insertUser(UserProfile user) async {
    try {
      final db = await database;
      return await db.insert('user_profile', user.toMap());
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
        return -1;
      } else {
        rethrow;
      }
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      final db = await database;
      final maps = await db.query('user_profile');
      return maps.map((e) => UserProfile.fromMap(e)).toList();
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
        return [];
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteAllUsers() async {
    try {
      final db = await database;
      await db.delete('user_profile');
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
      } else {
        rethrow;
      }
    }
  }

  // PostureAlert
  Future<int> insertAlert(PostureAlert alert) async {
    try {
      final db = await database;
      return await db.insert('posture_alert', alert.toMap());
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
        return -1;
      } else {
        rethrow;
      }
    }
  }

  Future<List<PostureAlert>> getAllAlerts() async {
    try {
      final db = await database;
      final maps = await db.query('posture_alert', orderBy: 'timestamp DESC');
      return maps.map((e) => PostureAlert.fromMap(e)).toList();
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
        return [];
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteAllAlerts() async {
    try {
      final db = await database;
      await db.delete('posture_alert');
    } catch (e) {
      if (kIsWeb) {
        print('Skip database insert on web: $e');
      } else {
        rethrow;
      }
    }
  }
}
