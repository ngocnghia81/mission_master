import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

/// Service để kết nối và tương tác với PostgreSQL database
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  /// Factory constructor trả về singleton instance
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();

  PostgreSQLConnection? _connection;
  final Map<int, PostgreSQLConnection> _connectionPool = {};
  int _lastConnectionId = 0;

  /// Lấy kết nối đến PostgreSQL
  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && _connection!.isClosed == false) {
      return _connection!;
    }

    _connection = PostgreSQLConnection(
      DatabaseConfig.host,
      DatabaseConfig.port,
      DatabaseConfig.databaseName,
      username: DatabaseConfig.username,
      password: DatabaseConfig.password,
    );

    await _connection!.open();
    return _connection!;
  }

  /// Lấy kết nối từ pool
  Future<PostgreSQLConnection> getPooledConnection() async {
    // Tìm kết nối có sẵn trong pool
    final availableConnection = _connectionPool.entries
        .where((entry) => entry.value.isClosed == false)
        .map((entry) => entry.value)
        .firstOrNull;

    if (availableConnection != null) {
      return availableConnection;
    }

    // Tạo kết nối mới nếu chưa đạt giới hạn
    if (_connectionPool.length < DatabaseConfig.maxConnections) {
      final newConnection = PostgreSQLConnection(
        DatabaseConfig.host,
        DatabaseConfig.port,
        DatabaseConfig.databaseName,
        username: DatabaseConfig.username,
        password: DatabaseConfig.password,
      );

      await newConnection.open();
      _lastConnectionId++;
      _connectionPool[_lastConnectionId] = newConnection;
      return newConnection;
    }

    // Nếu đã đạt giới hạn, đợi và thử lại
    await Future.delayed(const Duration(milliseconds: 100));
    return getPooledConnection();
  }

  /// Đóng tất cả các kết nối
  Future<void> closeAll() async {
    for (final conn in _connectionPool.values) {
      await conn.close();
    }
    _connectionPool.clear();

    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  /// Thực hiện truy vấn và trả về nhiều kết quả
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    Map<String, dynamic>? parameters,
  ]) async {
    final conn = await connection;
    final results = await conn.mappedResultsQuery(
      sql,
      substitutionValues: parameters,
    );

    return results.map((row) {
      final firstTableName = row.keys.first;
      return row[firstTableName]!;
    }).toList();
  }

  /// Thực hiện truy vấn và trả về một kết quả
  Future<Map<String, dynamic>?> queryOne(
    String sql, [
    Map<String, dynamic>? parameters,
  ]) async {
    final results = await query(sql, parameters);
    return results.isEmpty ? null : results.first;
  }

  /// Thực hiện truy vấn và trả về số hàng bị ảnh hưởng
  Future<int> execute(
    String sql, [
    Map<String, dynamic>? parameters,
  ]) async {
    final conn = await connection;
    return await conn.execute(
      sql,
      substitutionValues: parameters,
    );
  }

  /// Thực hiện truy vấn INSERT và trả về ID của bản ghi mới
  Future<int> insert(
    String sql, [
    Map<String, dynamic>? parameters,
  ]) async {
    final conn = await connection;
    final results = await conn.query(
      '$sql RETURNING id',
      substitutionValues: parameters,
    );
    
    return results.first[0] as int;
  }

  /// Thực hiện các truy vấn trong một transaction
  Future<T> transaction<T>(
    Future<T> Function(PostgreSQLExecutionContext) queries,
  ) async {
    final conn = await connection;
    return await conn.transaction(queries);
  }
}
