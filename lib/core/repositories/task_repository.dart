import '../models/task.dart';
import 'base_repository.dart';

/// Interface cho Task Repository
abstract class TaskRepository extends BaseRepository<Task> {
  /// Lấy danh sách nhiệm vụ theo dự án
  Future<List<Task>> getByProjectId(int projectId);
  
  /// Lấy danh sách nhiệm vụ được giao cho user
  Future<List<Task>> getByAssignedTo(int userId);
  
  /// Lấy danh sách nhiệm vụ do user giao
  Future<List<Task>> getByAssignedBy(int userId);
  
  /// Lấy danh sách nhiệm vụ theo trạng thái
  Future<List<Task>> getByStatus(String status);
  
  /// Lấy danh sách nhiệm vụ theo độ ưu tiên
  Future<List<Task>> getByPriority(String priority);
  
  /// Lấy danh sách nhiệm vụ theo membership ID
  Future<List<Task>> getByMembershipId(int membershipId);
  
  /// Cập nhật trạng thái nhiệm vụ
  Future<bool> updateStatus(int id, String status);
  
  /// Cập nhật người được giao nhiệm vụ
  Future<bool> updateAssignee(int taskId, int assigneeId);
  
  /// Cập nhật membership cho task
  Future<bool> updateMembership(int taskId, int membershipId);
  
  /// Đánh dấu nhiệm vụ đã hoàn thành
  Future<bool> markAsCompleted(int id, DateTime completedDate);
  
  /// Đánh dấu nhiệm vụ đã áp dụng phạt
  Future<bool> markAsPenaltyApplied(int id);
}
