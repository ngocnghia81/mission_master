import 'package:json_annotation/json_annotation.dart';
import 'package:mission_master/core/models/role.dart';
//
part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String email;
  final String username;
  final String fullName;
  final String role;
  final String? avatar;
  final String? phone;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  User({
    this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.role,
    this.avatar,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // Từ JSON thành User
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Debug print to check the structure of the json
      print('Creating User from json: $json');
      print('JSON keys: ${json.keys.toList()}');
      print('JSON types: ${json.map((k, v) => MapEntry(k, v?.runtimeType))}');

      // Xử lý chuyển đổi id từ String sang int nếu cần
      int? userId;
      if (json['id'] != null) {
        if (json['id'] is int) {
          userId = json['id'];
        } else if (json['id'] is String) {
          userId = int.tryParse(json['id'].toString());
        }
      }

      // Xử lý các trường có thể null
      final String email = json['email'] as String? ?? '';
      final String username = json['username'] as String? ?? '';
      final String fullName = json['full_name'] as String? ?? json['fullName'] as String? ?? '';
      final String role = json['role'] as String? ?? '';
      final bool isActive = json['is_active'] as bool? ?? json['isActive'] as bool? ?? true;
      
      // Xử lý các trường ngày tháng
      final String createdAt = json['created_at'] as String? ?? 
                              json['createdAt'] as String? ?? 
                              DateTime.now().toIso8601String();
      final String updatedAt = json['updated_at'] as String? ?? 
                              json['updatedAt'] as String? ?? 
                              DateTime.now().toIso8601String();

      // Handle potential null values safely
      return User(
        id: userId,
        email: email,
        username: username,
        fullName: fullName,
        role: role,
        avatar: json['avatar'] as String?,
        phone: json['phone'] as String?,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: json['deleted_at'] as String? ?? json['deletedAt'] as String?,
      );
    } catch (e) {
      print('Error creating User from json: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  // Từ User thành JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Từ Map trong database thành User
  factory User.fromMap(Map<String, dynamic> map) {
    try {
      print('Creating User from map: $map');
      
      // Xử lý chuyển đổi id từ String sang int nếu cần
      int? userId;
      if (map['id'] != null) {
        if (map['id'] is int) {
          userId = map['id'];
        } else if (map['id'] is String) {
          userId = int.tryParse(map['id']);
        }
      }
      
      // Xử lý các trường có thể null
      final String email = map['email'] as String? ?? '';
      final String username = map['username'] as String? ?? '';
      final String fullName = map['full_name'] as String? ?? map['fullName'] as String? ?? '';
      final String role = map['role'] as String? ?? '';
      final bool isActive = map['is_active'] as bool? ?? map['isActive'] as bool? ?? true;
      
      // Xử lý các trường ngày tháng
      final String createdAt = map['created_at'] as String? ?? 
                              map['createdAt'] as String? ?? 
                              DateTime.now().toIso8601String();
      final String updatedAt = map['updated_at'] as String? ?? 
                              map['updatedAt'] as String? ?? 
                              DateTime.now().toIso8601String();
      
      return User(
        id: userId,
        email: email,
        username: username,
        fullName: fullName,
        role: role,
        avatar: map['avatar'] as String?,
        phone: map['phone'] as String?,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: map['deleted_at'] as String? ?? map['deletedAt'] as String?,
      );
    } catch (e) {
      print('Error in User.fromMap: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  // Từ User thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'role': role,
      'avatar': avatar,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Kiểm tra vai trò của người dùng
  bool get isAdmin {
    print('Kiểm tra isAdmin: role=$role, UserRole.admin.name=${UserRole.admin.name}, so sánh: ${role == UserRole.admin.name}');
    return role == UserRole.admin.name;
  }
  
  bool get isManager {
    print('Kiểm tra isManager: role=$role, UserRole.manager.name=${UserRole.manager.name}, so sánh: ${role == UserRole.manager.name}');
    return role == UserRole.manager.name;
  }
  
  bool get isEmployee {
    print('Kiểm tra isEmployee: role=$role, UserRole.employee.name=${UserRole.employee.name}, so sánh: ${role == UserRole.employee.name}');
    return role == UserRole.employee.name;
  }

  // Kiểm tra xem user có phải là nhóm trưởng của dự án không
  bool isLeaderOfProject(int projectId) {
    // Cần truy vấn database để kiểm tra dự án có leader_id = user.id
    // Sẽ được triển khai trong repository
    return false;
  }

  // Lấy tên hiển thị của vai trò
  String get roleDisplayName => UserRole.fromString(role).displayName;

  // Sao chép với các giá trị mới
  User copyWith({
    int? id,
    String? email,
    String? username,
    String? fullName,
    String? role,
    String? avatar,
    String? phone,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
