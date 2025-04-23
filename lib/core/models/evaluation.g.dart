// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Evaluation _$EvaluationFromJson(Map<String, dynamic> json) => Evaluation(
      id: (json['id'] as num?)?.toInt(),
      taskId: (json['taskId'] as num).toInt(),
      attitudeScore: (json['attitudeScore'] as num).toInt(),
      qualityScore: (json['qualityScore'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$EvaluationToJson(Evaluation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'attitudeScore': instance.attitudeScore,
      'qualityScore': instance.qualityScore,
      'notes': instance.notes,
      'createdAt': instance.createdAt,
    };
