// lib/providers/task_provider.dart
// tasks(user) - task_details  - attachments(task) - penalties - evaluations
import 'package:flutter/material.dart';
import 'package:mission_master/core/models/evaluation.dart';
import 'package:mission_master/core/models/task.dart';
import 'package:mission_master/core/models/task_detail.dart';
import 'package:mission_master/core/models/attachment.dart';
import 'package:mission_master/core/models/penalty.dart';
import 'package:mission_master/core/models/comment.dart';
import 'package:mission_master/services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  final int userId;

  List<Task> _tasks = [];
  List<TaskDetail> _taskDetails = [];
  List<Attachment> _attachments = [];
  List<Penalty> _penalties = [];
  List<Evaluation> _evaluations = [];
  List<Comment> _comments = [];
  Map<int, double> _taskProgress = {};

  TaskProvider({required this.userId});

  List<Task> get tasks => _tasks;
  List<TaskDetail> get taskDetails => _taskDetails;
  List<Attachment> get attachments => _attachments;
  List<Penalty> get penalties => _penalties;
  List<Evaluation> get evaluations => _evaluations;
  List<Comment> get comments => _comments;
  Map<int, double> get taskProgress => _taskProgress;

  Future<void> loadUserData() async {
    try {
      final tasksData = await _loadTasks();
      final taskDetailsData = await _loadTaskDetails(tasksData);
      await _loadAttachments(taskDetailsData);
      await _loadPenalties(tasksData);
      await _loadEvaluations(tasksData);
      await _loadComments(tasksData);

      notifyListeners();
      print('Task data loaded successfully');
    } catch (e) {
      print('Lỗi khi load dữ liệu: $e');
      rethrow;
    }
  }

  // ----------------- CÁC HÀM TÁCH RIÊNG -----------------

Future<List<Map<String, dynamic>>> _loadTasks() async {
    final tasksData = await _api.getTasksByEmployeeId(userId);
    _tasks = tasksData.map((e) => Task.fromMap(e)).toList();
    print('Length task: ${tasksData.length}');
    return tasksData;
  }

  Future<List<Map<String, dynamic>>> _loadTaskDetails(List<Map<String, dynamic>> tasksData) async {
    List<Map<String, dynamic>> allTaskDetails = [];

    for (var taskMap in tasksData) {
      final taskId = taskMap['id'] as int?;
      if (taskId == null) {
        print('Task không có id: $taskMap');
        continue;
      }

      try {
        final taskDetails = await _api.getTaskDetailsByTaskId(taskId);

        allTaskDetails.addAll(taskDetails);

        final detailObjects = taskDetails.map((e) => TaskDetail.fromMap(e)).toList();
        _taskDetails.addAll(detailObjects);

        final double progress = calculateTaskProgress(detailObjects);
        _taskProgress[taskId] = progress;

        print('Task $taskId – Progress: ${progress.toStringAsFixed(2)}');
      } catch (e) {
        print('Lỗi khi load task details cho taskId $taskId: $e');
      }
    }

    print('Load task details successfully');
    return allTaskDetails;
  }


  Future<void> _loadAttachments(List<Map<String, dynamic>> taskDetailsData) async {
    for (var taskDetailMap in taskDetailsData) {
      final taskDetailId = taskDetailMap['id'] as int?;
      if (taskDetailId == null) {
        print('taskDetailMap không có id: $taskDetailMap');
        continue;
      }

      try {
        final attachments = await _api.getAttachmentsByTaskDetailId(taskDetailId);
        final attachmentObjects = attachments.map((e) => Attachment.fromMap(e)).toList();

        _attachments.addAll(attachmentObjects);
        print('Attachments for task detail $taskDetailId: $attachments');
        print('Length task detail $taskDetailId attachment: ${attachments.length}');
      } catch (e) {
        print('Lỗi khi load attachment cho taskDetailId $taskDetailId: $e');
      }
    }
    print('Load attachments successfully');
  }


  Future<void> _loadPenalties(List<Map<String, dynamic>> tasksData) async {
    for (var taskMap in tasksData) {
      final taskId = taskMap['id'] as int?;
      if (taskId == null) {
        print('Task không có id (penalties): $taskMap');
        continue;
      }

      try {
        print('Task $taskId – Loading penalties...');
        final penalties = await _api.getPenaltiesByTaskId(taskId);
        final penaltyObjects = penalties.map((e) => Penalty.fromMap(e)).toList();

        _penalties.addAll(penaltyObjects);
        print('Length task $taskId penalty: ${penalties.length}');
      } catch (e) {
        print('Lỗi khi load penalties cho taskId $taskId: $e');
      }
    }
  }

  Future<void> _loadEvaluations(List<Map<String, dynamic>> tasksData) async {
    for (var taskMap in tasksData) {
      final taskId = taskMap['id'] as int?;
      if (taskId == null) {
        print('Task không có id (evaluations): $taskMap');
        continue;
      }

      try {
        final evaluations = await _api.getEvaluationsByTaskId(taskId);
        final evaluationObjects = evaluations.map((e) => Evaluation.fromMap(e)).toList();

        _evaluations.addAll(evaluationObjects);
        print('Length task $taskId evaluation: ${evaluations.length}');
      } catch (e) {
        print('Lỗi khi load evaluations cho taskId $taskId: $e');
      }
    }
  }

  
  Future<void> _loadComments(List<Map<String, dynamic>> tasksData) async {
    for (var taskMap in tasksData) {
      final taskId = taskMap['id'] as int;
      final comments = await _api.getCommentsByTaskId(taskId);
      final commentObjects = comments.map((e) => Comment.fromMap(e)).toList();

      _comments.addAll(commentObjects);
      print('Length task $taskId Comment: ${comments.length}');
    }
  }

  // ----------------- HÀM TÍNH TIẾN ĐỘ -----------------
  double calculateTaskProgress(List<TaskDetail> taskDetails) {
    if (taskDetails.isEmpty) return 0.0;
    final completedCount =
        taskDetails.where((e) => e.status.toLowerCase() == 'completed').length;
    return completedCount / taskDetails.length;
  }
}
