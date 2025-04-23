import '../../core/repositories/base_repository.dart';
import '../database_service.dart';

/// Lớp cơ sở cho tất cả các repository PostgreSQL
abstract class BasePostgresRepository<T> implements BaseRepository<T> {
  final DatabaseService _db = DatabaseService();
  
  /// Tên bảng trong cơ sở dữ liệu
  String get tableName;
  
  /// Chuyển đổi từ Map sang đối tượng
  T fromMap(Map<String, dynamic> map);
  
  /// Chuyển đổi từ đối tượng sang Map
  Map<String, dynamic> toMap(T item);
  
  /// Lấy ID của đối tượng
  int? getId(T item);
  
  @override
  Future<List<T>> getAll() async {
    final results = await _db.query('SELECT * FROM $tableName');
    return results.map((row) => fromMap(row)).toList();
  }
  
  @override
  Future<T?> getById(int id) async {
    final result = await _db.queryOne(
      'SELECT * FROM $tableName WHERE id = @id',
      {'id': id},
    );
    
    return result != null ? fromMap(result) : null;
  }
  
  @override
  Future<T> create(T item) async {
    final map = toMap(item);
    map.remove('id'); // Loại bỏ ID để PostgreSQL tự động tạo
    
    final columns = map.keys.join(', ');
    final values = map.keys.map((key) => '@$key').join(', ');
    
    final id = await _db.insert(
      'INSERT INTO $tableName ($columns) VALUES ($values)',
      map,
    );
    
    // Lấy bản ghi vừa tạo
    final created = await getById(id);
    if (created == null) {
      throw Exception('Failed to create item');
    }
    
    return created;
  }
  
  @override
  Future<T?> update(T item) async {
    final id = getId(item);
    if (id == null) {
      throw Exception('ID is required for update');
    }
    
    final map = toMap(item);
    map.remove('id'); // Loại bỏ ID khỏi danh sách cập nhật
    
    final setClause = map.keys.map((key) => '$key = @$key').join(', ');
    
    await _db.execute(
      'UPDATE $tableName SET $setClause WHERE id = @id',
      {...map, 'id': id},
    );
    
    return getById(id);
  }
  
  @override
  Future<bool> delete(int id) async {
    final rowsAffected = await _db.execute(
      'DELETE FROM $tableName WHERE id = @id',
      {'id': id},
    );
    
    return rowsAffected > 0;
  }
}
