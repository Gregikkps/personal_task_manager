import 'dart:async';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  final Logger _logger = Logger();
  bool _isInitialized = false;

  Future<void> initDatabase() async {
    if (_isInitialized) {
      _logger.i('Database already initialized, skipping...');
      return;
    }

    try {
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      } else if (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'tasks.db');

      _database = await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      _isInitialized = true;

      if (kDebugMode) {
        _logger.i('Database initialized at: $path');
      }
    } catch (e, stackTrace) {
      _logger.e('Database init error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        deadline INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        weather_json TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        CONSTRAINT unique_location UNIQUE (latitude, longitude)
      )
    ''');

    await db.execute('CREATE INDEX idx_tasks_deadline ON tasks(deadline)');
    await db.execute(
      'CREATE INDEX idx_tasks_is_completed ON tasks(is_completed)',
    );
    await db.execute(
      'CREATE INDEX idx_weather_timestamp ON weather_cache(timestamp)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS weather_cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          weather_json TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          CONSTRAINT unique_location UNIQUE (latitude, longitude)
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_weather_timestamp ON weather_cache(timestamp)',
      );
    }
  }

  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initDatabase() first.');
    }
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
    _isInitialized = false;
  }
}
