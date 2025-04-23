import 'package:postgres/postgres.dart';

/// Service để kết nối và tương tác với cơ sở dữ liệu PostgreSQL
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  PostgreSQLConnection? _connection;

  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && _connection!.isClosed == false) {
      return _connection!;
    }

    _connection = PostgreSQLConnection(
      'localhost', // host
      5432, // port
      'mission_master', // database name
      username: 'postgres', // username
      password: 'password', // password
    );

    await _connection!.open();
    return _connection!;
  }

  /// Thực hiện truy vấn và trả về danh sách kết quả dạng Map
  Future<List<Map<String, dynamic>>> query(String sql, [Map<String, dynamic>? parameters]) async {
    final conn = await connection;
    final results = await conn.mappedResultsQuery(sql, substitutionValues: parameters);
    return results.map((row) => row.values.first).toList();
  }

  /// Thực hiện truy vấn và trả về một kết quả dạng Map
  Future<Map<String, dynamic>?> queryOne(String sql, [Map<String, dynamic>? parameters]) async {
    final results = await query(sql, parameters);
    return results.isNotEmpty ? results.first : null;
  }

  /// Thực hiện câu lệnh và trả về số dòng bị ảnh hưởng
  Future<int> execute(String sql, [Map<String, dynamic>? parameters]) async {
    final conn = await connection;
    return await conn.execute(sql, substitutionValues: parameters);
  }

  /// Thực hiện câu lệnh insert và trả về ID của bản ghi mới
  Future<int> insert(String sql, [Map<String, dynamic>? parameters]) async {
    final conn = await connection;
    final results = await conn.query(sql + ' RETURNING id', substitutionValues: parameters);
    return results.first[0] as int;
  }

  /// Đóng kết nối
  Future<void> close() async {
    if (_connection != null && _connection!.isClosed == false) {
      await _connection!.close();
    }
  }
}
