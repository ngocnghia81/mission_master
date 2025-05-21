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

      // Handle potential null values safely
      return User(
        id:
            json['id'] is int
                ? json['id']
                : int.tryParse(json['id']?.toString() ?? ''),
        email: json['email'] as String,
        username: json['username'] as String,
        fullName: json['full_name'] as String,
        role: json['role'] as String,
        avatar: json['avatar'] as String?, // Already nullable
        phone: json['phone'] as String?, // Already nullable
        isActive: json['is_active'] as bool,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
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
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      avatar: map['avatar'] as String?,
      phone: map['phone'] as String?,
      isActive: map['is_active'] as bool,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      deletedAt: map['deleted_at'] as String?,
    );
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
  bool get isAdmin => role == UserRole.admin.name;
  bool get isManager => role == UserRole.manager.name;
  bool get isEmployee => role == UserRole.employee.name;

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
