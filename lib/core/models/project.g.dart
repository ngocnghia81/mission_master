// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      status: json['status'] as String,
      managerId: (json['managerId'] as num?)?.toInt(),
      leaderId: (json['leaderId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'description': instance.description,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'status': instance.status,
      'managerId': instance.managerId,
      'leaderId': instance.leaderId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
