import 'package:json_annotation/json_annotation.dart';
import '../services/database_service.dart';
import '../../config/database_config.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final int projectId;
  final int? assignedTo;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.projectId,
    this.assignedTo,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConfig.columnId: id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'project_id': projectId,
      'assigned_to': assignedTo,
      'created_by': createdBy,
      DatabaseConfig.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseConfig.columnUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map[DatabaseConfig.columnId],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      projectId: map['project_id'],
      assignedTo: map['assigned_to'],
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map[DatabaseConfig.columnCreatedAt]),
      updatedAt: DateTime.parse(map[DatabaseConfig.columnUpdatedAt]),
    );
  }

  // CRUD Operations
  static Future<Task> create(Task task) async {
    final db = await DatabaseService.instance.database;
    final id = await db.insert(DatabaseConfig.tableTasks, task.toMap());
    return task.copyWith(id: id);
  }

  static Future<Task?> read(int id) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      DatabaseConfig.tableTasks,
      where: '${DatabaseConfig.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Task>> readAll() async {
    final db = await DatabaseService.instance.database;
    final result = await db.query(DatabaseConfig.tableTasks);
    return result.map((map) => Task.fromMap(map)).toList();
  }

  static Future<int> update(Task task) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      DatabaseConfig.tableTasks,
      task.toMap(),
      where: '${DatabaseConfig.columnId} = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DatabaseService.instance.database;
    return await db.delete(
      DatabaseConfig.tableTasks,
      where: '${DatabaseConfig.columnId} = ?',
      whereArgs: [id],
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    int? projectId,
    int? assignedTo,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
