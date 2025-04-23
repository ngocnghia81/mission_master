import '../models/penalty.dart';
import 'base_repository.dart';

/// Interface cho Penalty Repository
abstract class PenaltyRepository extends BaseRepository<Penalty> {
  /// Lấy phạt theo nhiệm vụ
  Future<Penalty?> getByTaskId(int taskId);
  
  /// Lấy danh sách phạt của các nhiệm vụ trong dự án
  Future<List<Penalty>> getByProjectId(int projectId);
  
  /// Lấy danh sách phạt của user
  Future<List<Penalty>> getByUserId(int userId);
  
  /// Cập nhật trạng thái đã thanh toán
  Future<bool> updatePaidStatus(int id, bool isPaid);
  
  /// Tính tổng tiền phạt của user
  Future<double> getTotalPenaltyAmountByUserId(int userId);
  
  /// Tính tổng tiền phạt của dự án
  Future<double> getTotalPenaltyAmountByProjectId(int projectId);
}
