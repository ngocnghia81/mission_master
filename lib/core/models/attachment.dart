import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

@JsonSerializable()
class Attachment {
  final int? id;
  final String fileName;
  final String filePath;
  final String fileType;
  final int projectId;
  final int? taskDetailId;
  final String createdAt;

  Attachment({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.projectId,
    this.taskDetailId,
    required this.createdAt,
  });

  // Từ JSON thành Attachment
  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  // Từ Attachment thành JSON
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  // Từ Map trong database thành Attachment
  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as int?,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      projectId: map['project_id'] as int,
      taskDetailId: map['task_id'] as int?,
      createdAt: map['created_at'] as String,
    );
  }

  // Từ Attachment thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'project_id': projectId,
      if (taskDetailId != null) 'task_detail_id': taskDetailId,
      'created_at': createdAt,
    };
  }

  // Sao chép với các giá trị mới
  Attachment copyWith({
    int? id,
    String? fileName,
    String? filePath,
    String? fileType,
    int? projectId,
    int? taskDetailId,
    String? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      projectId: projectId ?? this.projectId,
      taskDetailId: taskDetailId ?? this.taskDetailId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
