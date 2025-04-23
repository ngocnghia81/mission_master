/// Tiện ích để xử lý JSON
class JsonUtils {
  /// Chuyển đổi Map có chứa DateTime thành Map có thể chuyển đổi thành JSON
  static Map<String, dynamic> convertMapToJson(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is DateTime) {
        // Chuyển đổi DateTime thành chuỗi ISO8601
        result[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        // Đệ quy cho Map con
        result[key] = convertMapToJson(value);
      } else if (value is List) {
        // Xử lý List
        result[key] = _convertListToJson(value);
      } else {
        // Giữ nguyên các giá trị khác
        result[key] = value;
      }
    }
    
    return result;
  }
  
  /// Chuyển đổi List có chứa DateTime thành List có thể chuyển đổi thành JSON
  static List<dynamic> _convertListToJson(List<dynamic> list) {
    return list.map((item) {
      if (item is DateTime) {
        return item.toIso8601String();
      } else if (item is Map<String, dynamic>) {
        return convertMapToJson(item);
      } else if (item is List) {
        return _convertListToJson(item);
      } else {
        return item;
      }
    }).toList();
  }
  
  /// Chuyển đổi danh sách Map có chứa DateTime thành danh sách Map có thể chuyển đổi thành JSON
  static List<Map<String, dynamic>> convertListToJson(
    List<Map<String, dynamic>> list,
  ) {
    return list.map(convertMapToJson).toList();
  }
}
