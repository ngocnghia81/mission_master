import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../config/database_config.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConfig.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableUsers} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    // Create Projects table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableProjects} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        created_by INTEGER NOT NULL,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Tasks table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableTasks} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        due_date TEXT,
        project_id INTEGER NOT NULL,
        assigned_to INTEGER,
        created_by INTEGER NOT NULL,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES ${DatabaseConfig.tableProjects} (${DatabaseConfig.columnId}),
        FOREIGN KEY (assigned_to) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId}),
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Teams table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableTeams} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        project_id INTEGER NOT NULL,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES ${DatabaseConfig.tableProjects} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Comments table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableComments} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        task_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES ${DatabaseConfig.tableTasks} (${DatabaseConfig.columnId}),
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Attachments table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableAttachments} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        task_id INTEGER NOT NULL,
        uploaded_by INTEGER NOT NULL,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES ${DatabaseConfig.tableTasks} (${DatabaseConfig.columnId}),
        FOREIGN KEY (uploaded_by) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
