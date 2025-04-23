import 'package:json_annotation/json_annotation.dart';
import 'package:mission_master/core/models/role.dart';

part 'project.g.dart';

// Lớp enum để quản lý trạng thái dự án
enum ProjectStatus {
  notStarted,
  inProgress,
  completed,
  cancelled;

  static ProjectStatus fromString(String status) {
    switch (status) {
      case 'not_started':
        return ProjectStatus.notStarted;
      case 'in_progress':
        return ProjectStatus.inProgress;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.notStarted;
    }
  }

  String get value {
    switch (this) {
      case ProjectStatus.notStarted:
        return 'not_started';
      case ProjectStatus.inProgress:
        return 'in_progress';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.cancelled:
        return 'cancelled';
    }
  }
}

@JsonSerializable()
class Project {
  final int? id;
  final String name;
  final String? logo;
  final String? description;
  final String startDate;
  final String endDate;
  final String status; // Sử dụng ProjectStatus
  final int? managerId;
  final int? leaderId; // Id của nhân viên được chỉ định làm nhóm trưởng
  final String createdAt;
  final String updatedAt;

  Project({
    this.id,
    required this.name,
    this.logo,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.managerId,
    this.leaderId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Từ JSON thành Project
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  // Từ Project thành JSON
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  // Từ Map trong database thành Project
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      name: map['name'] as String,
      logo: map['logo'] as String?,
      description: map['description'] as String?,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      status: map['status'] as String,
      managerId: map['manager_id'] as int?,
      leaderId: map['leader_id'] as int?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Từ Project thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'logo': logo,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'manager_id': managerId,
      'leader_id': leaderId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Lấy trạng thái hiển thị của dự án
  String get statusDisplayName {
    switch (ProjectStatus.fromString(status)) {
      case ProjectStatus.notStarted:
        return 'Chưa bắt đầu';
      case ProjectStatus.inProgress:
        return 'Đang tiến hành';
      case ProjectStatus.completed:
        return 'Hoàn thành';
      case ProjectStatus.cancelled:
        return 'Đã hủy';
    }
  }

  // Kiểm tra trạng thái dự án
  bool get isNotStarted => status == ProjectStatus.notStarted.value;
  bool get isInProgress => status == ProjectStatus.inProgress.value;
  bool get isCompleted => status == ProjectStatus.completed.value;
  bool get isCancelled => status == ProjectStatus.cancelled.value;

  // Tính số ngày còn lại đến deadline
  int get daysRemaining {
    final now = DateTime.now();
    final end = DateTime.parse(endDate);
    return end.difference(now).inDays;
  }

  // Sao chép với các giá trị mới
  Project copyWith({
    int? id,
    String? name,
    String? logo,
    String? description,
    String? startDate,
    String? endDate,
    String? status,
    int? managerId,
    int? leaderId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      leaderId: leaderId ?? this.leaderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
