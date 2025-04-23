/// Interface cơ sở cho tất cả các repository
abstract class BaseRepository<T> {
  /// Lấy tất cả các bản ghi
  Future<List<T>> getAll();
  
  /// Lấy một bản ghi theo ID
  Future<T?> getById(int id);
  
  /// Tạo một bản ghi mới
  Future<T> create(T item);
  
  /// Cập nhật một bản ghi
  Future<T?> update(T item);
  
  /// Xóa một bản ghi theo ID
  Future<bool> delete(int id);
}
