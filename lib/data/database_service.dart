import 'package:mission_master/data/repositories/postgres_attachment_repository.dart';

/// Service để kết nối và tương tác với cơ sở dữ liệu PostgreSQL
/// Đây là một stub implementation không thực sự kết nối đến database
/// Vì chúng ta đang chuyển sang sử dụng API thay vì truy cập trực tiếp vào database
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Stub implementation - không thực sự kết nối đến database
  Future<dynamic> get connection async {
    throw UnimplementedError(
        'Database service has been replaced with ApiService');
  }

  /// Stub - không thực sự truy vấn database
  Future<List<Map<String, dynamic>>> query(String sql,
      [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError(
        'Database service has been replaced with ApiService');
  }

  /// Stub - không thực sự truy vấn database
  Future<Map<String, dynamic>?> queryOne(String sql,
      [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError(
        'Database service has been replaced with ApiService');
  }

  /// Stub - không thực sự thực thi câu lệnh SQL
  Future<int> execute(String sql, [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError(
        'Database service has been replaced with ApiService');
  }

  /// Stub - không thực sự chèn dữ liệu
  Future<int> insert(String sql, [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError(
        'Database service has been replaced with ApiService');
  }

  /// Stub - không thực sự đóng kết nối
  Future<void> close() async {
    // Không làm gì
  }
}
