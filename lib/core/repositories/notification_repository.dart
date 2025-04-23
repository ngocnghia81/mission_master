import '../models/notification.dart';
import 'base_repository.dart';

/// Interface cho Notification Repository
abstract class NotificationRepository extends BaseRepository<Notification> {
  /// Lấy danh sách thông báo của user
  Future<List<Notification>> getByUserId(int userId);
  
  /// Lấy danh sách thông báo chưa đọc của user
  Future<List<Notification>> getUnreadByUserId(int userId);
  
  /// Đánh dấu thông báo đã đọc
  Future<bool> markAsRead(int id);
  
  /// Đánh dấu tất cả thông báo của user đã đọc
  Future<bool> markAllAsRead(int userId);
  
  /// Lấy số lượng thông báo chưa đọc của user
  Future<int> getUnreadCount(int userId);
  
  /// Lấy danh sách thông báo theo loại
  Future<List<Notification>> getByType(String type, int userId);
}
