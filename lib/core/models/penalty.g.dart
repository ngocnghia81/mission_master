// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Penalty _$PenaltyFromJson(Map<String, dynamic> json) => Penalty(
      id: (json['id'] as num?)?.toInt(),
      taskId: (json['taskId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      daysOverdue: (json['daysOverdue'] as num).toInt(),
      isPaid: json['isPaid'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$PenaltyToJson(Penalty instance) => <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'amount': instance.amount,
      'reason': instance.reason,
      'daysOverdue': instance.daysOverdue,
      'isPaid': instance.isPaid,
      'createdAt': instance.createdAt,
    };
