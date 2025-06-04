import 'package:json_annotation/json_annotation.dart';

part 'penalty.g.dart';

/// Mô hình khoản phạt cho task trễ hạn.
/// Mỗi task có thể có 0 hoặc 1 khoản phạt duy nhất (task_id là UNIQUE trong database).
/// Mối quan hệ giữa task và penalty là 1-0..1 (một task có thể có nhiều nhất một khoản phạt).
@JsonSerializable()
class Penalty {
  final int? id;
  final int taskId;
  final double amount;
  final String reason;
  final bool isPaid;
  final String createdAt;

  Penalty({
    this.id,
    required this.taskId,
    required this.amount,
    required this.reason,
    required this.isPaid,
    required this.createdAt,
  });

  // Từ JSON thành Penalty
  factory Penalty.fromJson(Map<String, dynamic> json) =>
      _$PenaltyFromJson(json);

  // Từ Penalty thành JSON
  Map<String, dynamic> toJson() => _$PenaltyToJson(this);

  // Từ Map trong database thành Penalty
  factory Penalty.fromMap(Map<String, dynamic> map) {
    return Penalty(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      amount: map['amount'] as double,
      reason: map['reason'] as String,
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
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
