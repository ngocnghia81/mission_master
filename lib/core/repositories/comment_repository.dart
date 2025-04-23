import '../models/comment.dart';
import 'base_repository.dart';

/// Interface cho Comment Repository
abstract class CommentRepository extends BaseRepository<Comment> {
  /// Lấy danh sách bình luận theo nhiệm vụ
  Future<List<Comment>> getByTaskId(int taskId);
  
  /// Lấy danh sách bình luận của user
  Future<List<Comment>> getByUserId(int userId);
}
