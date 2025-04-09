import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  bool _hasIndex = true;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        age INTEGER NOT NULL
      )
    ''');

    // Create index on email field
    await db.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<List<User>> searchUsersByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email LIKE ?',
      whereArgs: ['%$email%'],
    );
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<bool> isIndexEnabled() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_users_email'",
    );
    return result.isNotEmpty;
  }

  Future<void> dropIndex() async {
    final db = await database;
    await db.execute('DROP INDEX IF EXISTS idx_users_email');
    _hasIndex = false;
  }

  Future<void> createIndex() async {
    final db = await database;
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
    );
    _hasIndex = true;
  }

  Future<String> explainQueryPlan(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'EXPLAIN QUERY PLAN $query',
    );
    return result.toString();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
