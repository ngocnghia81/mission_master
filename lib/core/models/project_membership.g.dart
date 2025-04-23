// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectMembership _$ProjectMembershipFromJson(Map<String, dynamic> json) =>
    ProjectMembership(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      projectId: (json['projectId'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ProjectMembershipToJson(ProjectMembership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'projectId': instance.projectId,
      'createdAt': instance.createdAt,
    };
