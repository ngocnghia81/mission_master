import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final int? relatedId;
  final bool isRead;
  final String createdAt;

  Notification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  // Từ JSON thành Notification
  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

  // Từ Notification thành JSON
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  // Từ Map trong database thành Notification
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      relatedId: map['related_id'] as int?,
      isRead: map['is_read'] as bool,
      createdAt: map['created_at'] as String,
    );
  }

  // Từ Notification thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }

  // Sao chép với các giá trị mới
  Notification copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    int? relatedId,
    bool? isRead,
    String? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
