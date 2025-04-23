import 'package:mission_master/data/database_service.dart';

import '../../core/models/task.dart';
import '../../core/repositories/task_repository.dart';
import 'base_postgres_repository.dart';

/// Triển khai PostgreSQL cho TaskRepository
class PostgresTaskRepository extends BasePostgresRepository<Task>
    implements TaskRepository {
  @override
  String get tableName => 'tasks';

  @override
  Task fromMap(Map<String, dynamic> map) => Task.fromMap(map);

  @override
  Map<String, dynamic> toMap(Task item) => item.toMap();

  @override
  int? getId(Task item) => item.id;

  @override
  Future<List<Task>> getByProjectId(int projectId) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE project_id = @projectId',
      {'projectId': projectId},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<List<Task>> getByAssignedTo(int userId) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE assigned_to = @userId',
      {'userId': userId},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<List<Task>> getByAssignedBy(int userId) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE assigned_by = @userId',
      {'userId': userId},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<List<Task>> getByStatus(String status) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE status = @status',
      {'status': status},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<List<Task>> getByPriority(String priority) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE priority = @priority',
      {'priority': priority},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<List<Task>> getByMembershipId(int membershipId) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE membership_id = @membershipId',
      {'membershipId': membershipId},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<bool> updateStatus(int id, String status) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET status = @status, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
      {'id': id, 'status': status},
    );

    return rowsAffected > 0;
  }

  @override
  Future<bool> updateAssignee(int taskId, int assigneeId) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET assigned_to = @assigneeId, updated_at = CURRENT_TIMESTAMP WHERE id = @taskId',
      {'taskId': taskId, 'assigneeId': assigneeId},
    );

    return rowsAffected > 0;
  }

  @override
  Future<bool> updateMembership(int taskId, int membershipId) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET membership_id = @membershipId, updated_at = CURRENT_TIMESTAMP WHERE id = @taskId',
      {'taskId': taskId, 'membershipId': membershipId},
    );

    return rowsAffected > 0;
  }

  @override
  Future<bool> markAsCompleted(int id, DateTime completedDate) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET status = \'completed\', completed_date = @completedDate, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
      {'id': id, 'completedDate': completedDate.toIso8601String()},
    );

    return rowsAffected > 0;
  }

  @override
  Future<bool> markAsPenaltyApplied(int id) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET is_penalty_applied = TRUE, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
      {'id': id},
    );

    return rowsAffected > 0;
  }

  // Thuộc tính để truy cập DatabaseService
  DatabaseService get db => DatabaseService();
}
