import 'package:json_annotation/json_annotation.dart';

part 'task_detail.g.dart';

/// Mô hình chi tiết nhiệm vụ.
/// Mỗi task có thể có nhiều task_details (1-n).
@JsonSerializable()
class TaskDetail {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final int taskId;
  final String createdAt;
  final String? deletedAt;

  TaskDetail({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.taskId,
    required this.createdAt,
    this.deletedAt,
  });

  // Từ JSON thành TaskDetail
  factory TaskDetail.fromJson(Map<String, dynamic> json) => _$TaskDetailFromJson(json);

  // Từ TaskDetail thành JSON
  Map<String, dynamic> toJson() => _$TaskDetailToJson(this);

  // Từ Map trong database thành TaskDetail
  factory TaskDetail.fromMap(Map<String, dynamic> map) {
    return TaskDetail(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: map['status'] as String,
      taskId: map['task_id'] as int,
      createdAt: map['created_at'] as String,
      deletedAt: map['deleted_at'] as String?,
    );
  }

  // Từ TaskDetail thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'status': status,
      'task_id': taskId,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }

  // Kiểm tra trạng thái của task detail
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isInCheck => status == 'in_check';

  // Lấy tên hiển thị của trạng thái
  String get statusDisplayName {
    switch (status) {
      case 'in_progress':
        return 'Đang thực hiện';
      case 'completed':
        return 'Đã hoàn thành';
      case 'in_check':
        return 'Đang kiểm tra';
      default:
        return 'Không xác định';
    }
  }

  // Sao chép với các giá trị mới
  TaskDetail copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    int? taskId,
    String? createdAt,
    String? deletedAt,
  }) {
    return TaskDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
