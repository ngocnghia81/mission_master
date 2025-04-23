import '../models/user.dart';
import 'base_repository.dart';

/// Interface cho User Repository
abstract class UserRepository extends BaseRepository<User> {
  /// Tìm user theo email
  Future<User?> findByEmail(String email);
  
  /// Tìm user theo username
  Future<User?> findByUsername(String username);
  
  /// Xác thực người dùng
  Future<User?> authenticate(String username, String password);
  
  /// Lấy danh sách user theo vai trò
  Future<List<User>> getByRole(String role);
  
  /// Cập nhật trạng thái kích hoạt của user
  Future<bool> updateActiveStatus(int id, bool isActive);
}
