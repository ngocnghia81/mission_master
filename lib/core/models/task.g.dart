// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
<<<<<<< HEAD
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      dueDays: (json['dueDays'] as num).toInt(),
      completedDate: json['completedDate'] == null
          ? null
=======
      dueDays: (json['dueDays'] as num).toInt(),
      completedDate: json['completedDate'] == null
          ? null
>>>>>>> develop
          : DateTime.parse(json['completedDate'] as String),
      assignedTo: (json['assignedTo'] as num?)?.toInt(),
      createdBy: (json['createdBy'] as num).toInt(),
      membershipId: (json['membershipId'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
<<<<<<< HEAD
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
=======
>>>>>>> develop
      'dueDays': instance.dueDays,
      'completedDate': instance.completedDate?.toIso8601String(),
      'assignedTo': instance.assignedTo,
      'createdBy': instance.createdBy,
      'membershipId': instance.membershipId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
