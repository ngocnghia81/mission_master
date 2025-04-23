import '../../config/database_config.dart';

/// Dịch vụ cơ sở dữ liệu cho ứng dụng Flutter
/// 
/// Lớp này đã được thay thế bằng ApiService, đây chỉ là một stub để tương thích với các file cũ
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  // Stub implementation - không thực sự kết nối đến database
  DatabaseService._internal();
  
  /// Stub - không thực sự kết nối đến database
  Future<dynamic> get database async {
    throw UnimplementedError('Database service has been replaced with ApiService');
  }
  
  /// Stub - không thực sự truy vấn database
  Future<List<Map<String, dynamic>>> query(String sql, [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError('Database service has been replaced with ApiService');
  }
  
  /// Stub - không thực sự truy vấn database
  Future<Map<String, dynamic>?> queryOne(String sql, [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError('Database service has been replaced with ApiService');
  }
  
  /// Stub - không thực sự thực thi câu lệnh SQL
  Future<int> execute(String sql, [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError('Database service has been replaced with ApiService');
  }
  
  /// Stub - không thực sự chèn dữ liệu
  Future<int> insert(String sql, [Map<String, dynamic>? parameters]) async {
    throw UnimplementedError('Database service has been replaced with ApiService');
  }
  
  /// Stub - không thực sự đóng kết nối
  Future<void> close() async {
    // Không làm gì
  }
}
