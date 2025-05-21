import 'package:json_annotation/json_annotation.dart';

part 'project_membership.g.dart';

@JsonSerializable()
class ProjectMembership {
  final int? id;
  final int userId;
  final int projectId;
  final String createdAt;
  final String? deletedAt;

  ProjectMembership({
    this.id,
    required this.userId,
    required this.projectId,
    required this.createdAt,
    this.deletedAt,
  });

  // Từ JSON thành ProjectMembership
  factory ProjectMembership.fromJson(Map<String, dynamic> json) =>
      _$ProjectMembershipFromJson(json);

  // Từ ProjectMembership thành JSON
  Map<String, dynamic> toJson() => _$ProjectMembershipToJson(this);

  // Từ Map trong database thành ProjectMembership
  factory ProjectMembership.fromMap(Map<String, dynamic> map) {
    return ProjectMembership(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      projectId: map['project_id'] as int,
      createdAt: map['created_at'] as String,
      deletedAt: map['deleted_at'] as String?,
    );
  }

  // Từ ProjectMembership thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'project_id': projectId,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }

  // Sao chép với các giá trị mới
  ProjectMembership copyWith({
    int? id,
    int? userId,
    int? projectId,
    String? createdAt,
    String? deletedAt,
  }) {
    return ProjectMembership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
