// Author: Pravasta Rama - 2026

import 'package:sqflite/sqflite.dart';

/// [DatabaseHelper] A helper class for database operations.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/health_app.db';

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE infusion_cache (
        id INTEGER PRIMARY KEY,
        patient_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        infusion_name TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT CHECK( status IN ('scheduled', 'stopped', 'running', 'completed') ) NOT NULL DEFAULT 'scheduled',
        notification_id INTEGER,
        created_at TEXT NOT NULL
      );
    ''');
  }
}
