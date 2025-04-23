import '../models/attachment.dart';
import 'base_repository.dart';

/// Interface cho Attachment Repository
abstract class AttachmentRepository extends BaseRepository<Attachment> {
  /// Lấy danh sách tệp đính kèm theo project ID
  Future<List<Attachment>> getByProjectId(int projectId);
  
  /// Lấy danh sách tệp đính kèm theo loại file
  Future<List<Attachment>> getByFileType(String fileType);
  
  /// Lấy danh sách tệp đính kèm theo task ID
  Future<List<Attachment>> getByTaskId(int taskId);
  
  /// Liên kết tệp đính kèm với task
  Future<bool> linkToTask(int attachmentId, int taskId);
  
  /// Hủy liên kết tệp đính kèm với task
  Future<bool> unlinkFromTask(int attachmentId);
}
