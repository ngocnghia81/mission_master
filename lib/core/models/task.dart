import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final int projectId;
  final int? assignedTo;
  final int createdBy;
  final int? membershipId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.projectId,
    this.assignedTo,
    required this.createdBy,
    this.membershipId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'project_id': projectId,
      'assigned_to': assignedTo,
      'created_by': createdBy,
      if (membershipId != null) 'membership_id': membershipId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      projectId: map['project_id'],
      assignedTo: map['assigned_to'],
      createdBy: map['created_by'],
      membershipId: map['membership_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
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
    DateTime? dueDate,
    int? projectId,
    int? assignedTo,
    int? createdBy,
    int? membershipId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      membershipId: membershipId ?? this.membershipId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
