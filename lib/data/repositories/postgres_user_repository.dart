import 'package:mission_master/data/database_service.dart';

import '../../core/models/user.dart';
import '../../core/repositories/user_repository.dart';
import 'base_postgres_repository.dart';

/// Triển khai PostgreSQL cho UserRepository
class PostgresUserRepository extends BasePostgresRepository<User> implements UserRepository {
  @override
  String get tableName => 'users';
  
  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);
  
  @override
  Map<String, dynamic> toMap(User item) => item.toMap();
  
  @override
  int? getId(User item) => item.id;
  
  @override
  Future<User?> findByEmail(String email) async {
    final result = await db.queryOne(
      'SELECT * FROM $tableName WHERE email = @email',
      {'email': email},
    );
    
    return result != null ? fromMap(result) : null;
  }
  
  @override
  Future<User?> findByUsername(String username) async {
    final result = await db.queryOne(
      'SELECT * FROM $tableName WHERE username = @username',
      {'username': username},
    );
    
    return result != null ? fromMap(result) : null;
  }
  
  @override
  Future<User?> authenticate(String username, String password) async {
    // Trong thực tế, bạn sẽ cần kiểm tra mật khẩu đã hash
    // Đây chỉ là ví dụ đơn giản
    final result = await db.queryOne(
      'SELECT * FROM $tableName WHERE username = @username AND password = @password',
      {'username': username, 'password': password},
    );
    
    return result != null ? fromMap(result) : null;
  }
  
  @override
  Future<List<User>> getByRole(String role) async {
    final results = await db.query(
      'SELECT * FROM $tableName WHERE role = @role',
      {'role': role},
    );
    
    return results.map((row) => fromMap(row)).toList();
  }
  
  @override
  Future<bool> updateActiveStatus(int id, bool isActive) async {
    final rowsAffected = await db.execute(
      'UPDATE $tableName SET is_active = @isActive, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
      {'id': id, 'isActive': isActive},
    );
    
    return rowsAffected > 0;
  }
  
  // Thuộc tính để truy cập DatabaseService
  DatabaseService get db => DatabaseService();
}
