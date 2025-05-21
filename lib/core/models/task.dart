import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final int dueDays;
  final DateTime? completedDate;
  final int? assignedTo;
  final int createdBy;
  final int membershipId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.dueDays,
    this.completedDate,
    this.assignedTo,
    required this.createdBy,
    required this.membershipId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_days': dueDays,
      'completed_date': completedDate?.toIso8601String(),
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'membership_id': membershipId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      dueDays: map['due_days'] as int,
      completedDate: map['completed_date'] != null ? DateTime.parse(map['completed_date']) : null,
      assignedTo: map['assigned_to'],
      createdBy: map['created_by'],
      membershipId: map['membership_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  // Helper methods for JSON serialization
  factory Task.fromJson(Map<String, dynamic> json) => Task.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    int? dueDays,
    DateTime? completedDate,
    int? assignedTo,
    int? createdBy,
    int? membershipId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDays: dueDays ?? this.dueDays,
      completedDate: completedDate ?? this.completedDate,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      membershipId: membershipId ?? this.membershipId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
