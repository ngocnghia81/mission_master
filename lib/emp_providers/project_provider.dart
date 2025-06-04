// lib/providers/user_provider.dart
// projects(user) - project_memberships - attachments(project) - comments
import 'package:flutter/material.dart';
import 'package:mission_master/core/models/project.dart';
import 'package:mission_master/core/models/project_membership.dart';
import 'package:mission_master/core/models/attachment.dart';
import 'package:mission_master/core/models/task.dart';
import 'package:mission_master/services/api_service.dart';

import 'package:mission_master/emp_providers/task_provider.dart';

class ProjectProvider extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  final ApiService _api = ApiService.instance;
  final int userId;
  final TaskProvider taskProvider;

  List<Project> _projects = [];
  List<ProjectMembership> _project_memberships = [];
  List<Attachment> _attachments = [];

  Map<int, double> _projectProgress = {};

  ProjectProvider({required this.userId, required this.taskProvider});

  List<Project> get projects => _projects;
  List<ProjectMembership> get projectMemberships => _project_memberships;
  List<Attachment> get attachments => _attachments;
  Map<int, double> get projectProgress => _projectProgress;

  Future<void> loadUserData() async {
    try {
      final projectsData = await _loadProjects();
      await _loadProjectMemberships(projectsData);
      await _loadAttachments(projectsData);
      await calculateProjectProgressFromMemberships(taskProvider);

      notifyListeners();
      print('Project data loaded successfully');
    } catch (e) {
      print('Lỗi khi load dữ liệu: $e');
      rethrow;
    }
  }

  // ----------------- CÁC HÀM TÁCH RIÊNG -----------------

  Future<List<Map<String, dynamic>>> _loadProjects() async {
    final projectsData = await _api.getProjectsByUserId(userId);
    _projects = projectsData.map((e) => Project.fromMap(e)).toList();
    print('Length project: ${projectsData.length}');
    return projectsData;
  }

  Future<void> _loadProjectMemberships(
      List<Map<String, dynamic>> projectsData) async {
    for (var projectMap in projectsData) {
      final projectId = projectMap['id'] as int;
      final projectMemberships = await _api.getMembersByProjectId(projectId);
      final MembershipObjects =
          projectMemberships.map((e) => ProjectMembership.fromMap(e)).toList();

      _project_memberships.addAll(MembershipObjects);
      print(
          'Length project $projectId membership: ${projectMemberships.length}');
    }
  }

  Future<void> _loadAttachments(List<Map<String, dynamic>> projectsData) async {
    for (var projectMap in projectsData) {
      final projectId = projectMap['id'] as int;
      final attachments = await _api.getAttachmentsByProjectId(projectId);
      final attachmentObjects =
          attachments.map((e) => Attachment.fromMap(e)).toList();

      _attachments.addAll(attachmentObjects);
      print('Length project $projectId attachment: ${attachments.length}');
    }
  }

  Future<void> calculateProjectProgressFromMemberships(
      TaskProvider taskProvider) async {
    // Gom tất cả task thành map theo membership_id
    final Map<int, List<Task>> tasksByMembership = {};
    for (var task in taskProvider.tasks) {
      final membershipId = task.membershipId;
      if (membershipId != null) {
        tasksByMembership.putIfAbsent(membershipId, () => []).add(task);
      }
    }

    // Tính tiến độ cho từng project
    for (var project in _projects) {
      final int projectId = project.id as int;

      // Lấy membership của project này
      final memberships =
          _project_memberships.where((m) => m.projectId == projectId).toList();

      // Gom toàn bộ task thuộc các membership này
      List<Task> projectTasks = [];
      for (var membership in memberships) {
        projectTasks.addAll(tasksByMembership[membership.id] ?? []);
      }

      final progress = _calculateProgressFromTasks(projectTasks);
      _projectProgress[projectId] = progress;

      print('Project $projectId – Progress: ${progress.toStringAsFixed(2)}');
    }

    notifyListeners();
    print('Project progress calculated successfully');
  }

  // ----------------- HÀM TÍNH TIẾN ĐỘ -----------------
  // Tính toán tỷ lệ công việc của từng dự án
  double _calculateProgressFromTasks(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed =
        tasks.where((t) => t.status.toLowerCase() == 'completed').length;
    return completed / tasks.length;
  }
}
