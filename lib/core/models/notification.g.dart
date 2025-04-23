// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      relatedId: (json['relatedId'] as num?)?.toInt(),
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'relatedId': instance.relatedId,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
    };
