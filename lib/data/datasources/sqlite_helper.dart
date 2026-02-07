import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteHelper {
  static const String _dbName = 'workout.db';
  static const int _dbVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Photos Table
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        zone_type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        captured_at INTEGER NOT NULL,
        UNIQUE(date, zone_type)
      )
    ''');
    await db.execute('CREATE INDEX idx_photos_date ON photos (date)');
    await db.execute('CREATE INDEX idx_photos_zone ON photos (zone_type)');

    // 2. Macros Table
    await db.execute('''
      CREATE TABLE macros (
        date TEXT PRIMARY KEY,
        calories REAL DEFAULT 0,
        protein REAL DEFAULT 0,
        carbs REAL DEFAULT 0,
        fat REAL DEFAULT 0,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 3. Measurements Table
    await db.execute('''
      CREATE TABLE measurements (
        date TEXT PRIMARY KEY,
        weight REAL DEFAULT 0,
        waist REAL DEFAULT 0,
        chest REAL DEFAULT 0,
        hips REAL DEFAULT 0,
        neck REAL DEFAULT 0,
        arm_right REAL DEFAULT 0,
        arm_left REAL DEFAULT 0,
        thigh_right REAL DEFAULT 0,
        thigh_left REAL DEFAULT 0,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
