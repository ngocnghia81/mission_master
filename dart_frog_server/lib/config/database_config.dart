/// Cấu hình kết nối đến PostgreSQL database
class DatabaseConfig {
  /// Host của PostgreSQL server
  static const String host = 'localhost';

  /// Port của PostgreSQL server
  static const int port = 5432;

  /// Tên database
  static const String databaseName = 'mission_master';

  /// Username để đăng nhập vào PostgreSQL
  static const String username = 'postgres';

  /// Password để đăng nhập vào PostgreSQL
  static const String password = '5612';

  /// Số lượng kết nối tối đa trong pool
  static const int maxConnections = 10;
}
