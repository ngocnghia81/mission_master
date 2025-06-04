import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
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
    required this.startDate,
    this.endDate,
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
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'due_days': dueDays,
      'completed_date': completedDate?.toIso8601String(),
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'membership_id': membershipId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?, // Đã là nullable
      title: map['title'] as String? ?? '', // Giá trị mặc định nếu null
      description: map['description'] as String?,
      status:
          map['status'] as String? ?? 'pending', // Giá trị mặc định nếu null
      priority:
          map['priority'] as String? ?? 'medium', // Giá trị mặc định nếu null
      startDate:
          map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      dueDays: map['due_days'] as int? ?? 0, // Giá trị mặc định nếu null
      completedDate: map['completed_date'] != null
          ? DateTime.parse(map['completed_date'])
          : null,
      assignedTo: map['assigned_to'] as int?,
      createdBy: map['created_by'] as int? ?? 0, // Giá trị mặc định nếu null
      membershipId:
          map['membership_id'] as int? ?? 0, // Giá trị mặc định nếu null
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
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
    DateTime? startDate,
    DateTime? endDate,
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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
