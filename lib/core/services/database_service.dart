import 'dart:async';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  Database? _database;
  final Logger _logger = Logger();

  Future<void> initDatabase() async {
    try {
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      } else {
        databaseFactory = databaseFactory;
      }

      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'tasks.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              deadline INTEGER NOT NULL,  -- Unix timestamp
              is_completed INTEGER NOT NULL DEFAULT 0,  -- 0 false, 1 true
              completed_at INTEGER  -- Unix dla statystyk
            )
          ''');
        },
      );
      if (kDebugMode) {
        _logger.i('Database initialized at: $path');
      }
    } catch (e) {
      _logger.e('Database init error: $e');
      rethrow;
    }
  }

  Database get database {
    if (_database == null) throw Exception('Database not initialized');
    return _database!;
  }

  Future<void> close() async => _database?.close();
}
