import '../models/project.dart';
import 'base_repository.dart';

/// Interface cho Project Repository
abstract class ProjectRepository extends BaseRepository<Project> {
  /// Lấy danh sách dự án theo manager
  Future<List<Project>> getByManagerId(int managerId);
  
  /// Lấy danh sách dự án theo leader
  Future<List<Project>> getByLeaderId(int leaderId);
  
  /// Lấy danh sách dự án theo trạng thái
  Future<List<Project>> getByStatus(String status);
  
  /// Lấy danh sách dự án mà user tham gia
  Future<List<Project>> getByUserId(int userId);
  
  /// Cập nhật trạng thái dự án
  Future<bool> updateStatus(int id, String status);
  
  /// Cập nhật leader của dự án
  Future<bool> updateLeader(int projectId, int? leaderId);
}
