// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      id: (json['id'] as num?)?.toInt(),
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileType: json['fileType'] as String,
      projectId: (json['projectId'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'filePath': instance.filePath,
      'fileType': instance.fileType,
      'projectId': instance.projectId,
      'createdAt': instance.createdAt,
    };
