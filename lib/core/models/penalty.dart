import 'package:json_annotation/json_annotation.dart';

part 'penalty.g.dart';

@JsonSerializable()
class Penalty {
  final int? id;
  final int taskId;
  final double amount;
  final String reason;
  final int daysOverdue;
  final bool isPaid;
  final String createdAt;

  Penalty({
    this.id,
    required this.taskId,
    required this.amount,
    required this.reason,
    required this.daysOverdue,
    required this.isPaid,
    required this.createdAt,
  });

  // Từ JSON thành Penalty
  factory Penalty.fromJson(Map<String, dynamic> json) => _$PenaltyFromJson(json);

  // Từ Penalty thành JSON
  Map<String, dynamic> toJson() => _$PenaltyToJson(this);

  // Từ Map trong database thành Penalty
  factory Penalty.fromMap(Map<String, dynamic> map) {
    return Penalty(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      amount: map['amount'] as double,
      reason: map['reason'] as String,
      daysOverdue: map['days_overdue'] as int,
      isPaid: map['is_paid'] as bool,
      createdAt: map['created_at'] as String,
    );
  }

  // Từ Penalty thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'amount': amount,
      'reason': reason,
      'days_overdue': daysOverdue,
      'is_paid': isPaid,
      'created_at': createdAt,
    };
  }

  // Sao chép với các giá trị mới
  Penalty copyWith({
    int? id,
    int? taskId,
    double? amount,
    String? reason,
    int? daysOverdue,
    bool? isPaid,
    String? createdAt,
  }) {
    return Penalty(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      daysOverdue: daysOverdue ?? this.daysOverdue,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
