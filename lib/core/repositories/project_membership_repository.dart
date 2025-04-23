import '../models/project_membership.dart';
import 'base_repository.dart';

/// Interface cho ProjectMembership Repository
abstract class ProjectMembershipRepository extends BaseRepository<ProjectMembership> {
  /// Lấy danh sách thành viên của dự án
  Future<List<ProjectMembership>> getByProjectId(int projectId);
  
  /// Lấy danh sách dự án mà user tham gia
  Future<List<ProjectMembership>> getByUserId(int userId);
  
  /// Kiểm tra user có phải là thành viên của dự án không
  Future<bool> isMember(int userId, int projectId);
  
  /// Thêm user vào dự án
  Future<ProjectMembership> addUserToProject(int userId, int projectId);
  
  /// Xóa user khỏi dự án
  Future<bool> removeUserFromProject(int userId, int projectId);
}
