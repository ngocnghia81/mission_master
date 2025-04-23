import '../models/evaluation.dart';
import 'base_repository.dart';

/// Interface cho Evaluation Repository
abstract class EvaluationRepository extends BaseRepository<Evaluation> {
  /// Lấy đánh giá theo nhiệm vụ
  Future<Evaluation?> getByTaskId(int taskId);
  
  /// Lấy danh sách đánh giá của các nhiệm vụ trong dự án
  Future<List<Evaluation>> getByProjectId(int projectId);
  
  /// Lấy điểm đánh giá trung bình của user
  Future<Map<String, double>> getAverageScoresByUserId(int userId);
}
