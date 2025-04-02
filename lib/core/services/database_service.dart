import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/database_config.dart';

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
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'employee')),
        avatar TEXT,
        phone TEXT,
        is_active BOOLEAN NOT NULL DEFAULT 1,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    // Create Projects table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableProjects} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        logo TEXT,
        description TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('not_started', 'in_progress', 'completed', 'cancelled')),
        manager_id INTEGER NOT NULL,
        leader_id INTEGER,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (manager_id) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId}),
        FOREIGN KEY (leader_id) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Project Memberships table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableProjectMemberships} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        project_id INTEGER NOT NULL,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId}),
        FOREIGN KEY (project_id) REFERENCES ${DatabaseConfig.tableProjects} (${DatabaseConfig.columnId}),
        UNIQUE(user_id, project_id)
      )
    ''');

    // Create Tasks table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableTasks} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL CHECK (status IN ('not_assigned', 'in_progress', 'completed', 'overdue')),
        priority TEXT NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
        start_date TEXT,
        due_date TEXT NOT NULL,
        completed_date TEXT,
        project_id INTEGER NOT NULL,
        user_project_id INTEGER,
        assigned_by INTEGER NOT NULL,
        is_penalty_applied BOOLEAN DEFAULT 0,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConfig.columnUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES ${DatabaseConfig.tableProjects} (${DatabaseConfig.columnId}),
        FOREIGN KEY (user_project_id) REFERENCES ${DatabaseConfig.tableProjectMemberships} (${DatabaseConfig.columnId}),
        FOREIGN KEY (assigned_by) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
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
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES ${DatabaseConfig.tableTasks} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Evaluations table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableEvaluations} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        attitude_score INTEGER NOT NULL CHECK (attitude_score BETWEEN 0 AND 5),
        quality_score INTEGER NOT NULL CHECK (quality_score BETWEEN 0 AND 5),
        evaluator_id INTEGER NOT NULL,
        notes TEXT,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES ${DatabaseConfig.tableTasks} (${DatabaseConfig.columnId}),
        FOREIGN KEY (evaluator_id) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Penalties table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tablePenalties} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        reason TEXT NOT NULL,
        is_paid BOOLEAN NOT NULL DEFAULT 0,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES ${DatabaseConfig.tableTasks} (${DatabaseConfig.columnId})
      )
    ''');

    // Create Notifications table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableNotifications} (
        ${DatabaseConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        related_id INTEGER,
        is_read BOOLEAN NOT NULL DEFAULT 0,
        ${DatabaseConfig.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers} (${DatabaseConfig.columnId})
      )
    ''');

    // Insert admin user
    await db.insert(
      DatabaseConfig.tableUsers,
      {
        'email': 'admin@missionmaster.com',
        'username': 'admin',
        'password': 'admin123', // In production, use hashed password
        'full_name': 'System Administrator',
        'role': 'admin',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
