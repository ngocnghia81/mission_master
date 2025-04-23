import 'package:json_annotation/json_annotation.dart';

part 'evaluation.g.dart';

@JsonSerializable()
class Evaluation {
  final int? id;
  final int taskId;
  final int attitudeScore;
  final int qualityScore;
  final String? notes;
  final String createdAt;

  Evaluation({
    this.id,
    required this.taskId,
    required this.attitudeScore,
    required this.qualityScore,
    this.notes,
    required this.createdAt,
  });

  // Từ JSON thành Evaluation
  factory Evaluation.fromJson(Map<String, dynamic> json) => _$EvaluationFromJson(json);

  // Từ Evaluation thành JSON
  Map<String, dynamic> toJson() => _$EvaluationToJson(this);

  // Từ Map trong database thành Evaluation
  factory Evaluation.fromMap(Map<String, dynamic> map) {
    return Evaluation(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      attitudeScore: map['attitude_score'] as int,
      qualityScore: map['quality_score'] as int,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  // Từ Evaluation thành Map cho database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'attitude_score': attitudeScore,
      'quality_score': qualityScore,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  // Sao chép với các giá trị mới
  Evaluation copyWith({
    int? id,
    int? taskId,
    int? attitudeScore,
    int? qualityScore,
    String? notes,
    String? createdAt,
  }) {
    return Evaluation(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      attitudeScore: attitudeScore ?? this.attitudeScore,
      qualityScore: qualityScore ?? this.qualityScore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Tính điểm trung bình
  double get averageScore => (attitudeScore + qualityScore) / 2;
}
