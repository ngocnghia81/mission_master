import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final int? id;
  final String content;
  final int taskId;
  final int userId;
  final String createdAt;
  final String updatedAt;

  Comment({
    this.id,
    required this.content,
    required this.taskId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Từ JSON thành Comment
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  // Từ Comment thành JSON
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  // Từ Map trong database thành Comment
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int?,
      content: map['content'] as String,
      taskId: map['task_id'] as int,
      userId: map['user_id'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Từ Comment thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'task_id': taskId,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Sao chép với các giá trị mới
  Comment copyWith({
    int? id,
    String? content,
    int? taskId,
    int? userId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
