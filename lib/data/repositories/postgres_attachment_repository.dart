import '../../core/models/attachment.dart';
import '../../core/repositories/attachment_repository.dart';
import '../database_service.dart';
import 'base_postgres_repository.dart';

/// Triển khai PostgreSQL cho AttachmentRepository
class PostgresAttachmentRepository extends BasePostgresRepository<Attachment>
    implements AttachmentRepository {
  @override
  String get tableName => 'attachments';

  @override
  Attachment fromMap(Map<String, dynamic> map) => Attachment.fromMap(map);

  @override
  Map<String, dynamic> toMap(Attachment item) => item.toMap();

  @override
  int? getId(Attachment item) => item.id;

  @override
  Future<List<Attachment>> getByProjectId(int projectId) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE project_id = @projectId',
      {'projectId': projectId},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<List<Attachment>> getByFileType(String fileType) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE file_type = @fileType',
      {'fileType': fileType},
    );

    return results.map((row) => fromMap(row)).toList();
  }
  
  @override
  Future<List<Attachment>> getByTaskId(int taskId) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE task_id = @taskId',
      {'taskId': taskId},
    );

    return results.map((row) => fromMap(row)).toList();
  }

  @override
  Future<bool> linkToTask(int attachmentId, int taskId) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET task_id = @taskId WHERE id = @id',
      {'id': attachmentId, 'taskId': taskId},
    );

    return rowsAffected > 0;
  }

  @override
  Future<bool> unlinkFromTask(int attachmentId) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET task_id = NULL WHERE id = @id',
      {'id': attachmentId},
    );

    return rowsAffected > 0;
  }

  // Thuộc tính để truy cập DatabaseService
  DatabaseService get db => DatabaseService();
}
