// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/api/user/index.dart' as api_user_index;
import '../routes/api/tasks/attachments/index.dart' as api_tasks_attachments_index;
import '../routes/api/manager/projects/index.dart' as api_manager_projects_index;
import '../routes/api/employee/tasks/index.dart' as api_employee_tasks_index;
import '../routes/api/employee/task_details/index.dart' as api_employee_task_details_index;
import '../routes/api/employee/projects/index.dart' as api_employee_projects_index;
import '../routes/api/employee/project_memberships/index.dart' as api_employee_project_memberships_index;
import '../routes/api/employee/penalties/index.dart' as api_employee_penalties_index;
import '../routes/api/employee/notifications/index.dart' as api_employee_notifications_index;
import '../routes/api/employee/evaluations/index.dart' as api_employee_evaluations_index;
import '../routes/api/employee/comments/index.dart' as api_employee_comments_index;
import '../routes/api/employee/attachments/index.dart' as api_employee_attachments_index;
import '../routes/api/auth/register/index.dart' as api_auth_register_index;
import '../routes/api/auth/login/index.dart' as api_auth_login_index;
import '../routes/api/admin/users/index.dart' as api_admin_users_index;
import '../routes/api/admin/users/[id]/status.dart' as api_admin_users_$id_status;
import '../routes/api/admin/users/[id]/index.dart' as api_admin_users_$id_index;
import '../routes/api/admin/users/[id]/tasks/index.dart' as api_admin_users_$id_tasks_index;
import '../routes/api/admin/users/[id]/tasks/statistics/index.dart' as api_admin_users_$id_tasks_statistics_index;
import '../routes/api/admin/users/[id]/tasks/count/index.dart' as api_admin_users_$id_tasks_count_index;

import '../routes/_middleware.dart' as middleware;

void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8081') ?? 8081;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/api/admin/users/<id>/tasks/count', (context,id,) => buildApiAdminUsers$idTasksCountHandler(id,)(context))
    ..mount('/api/admin/users/<id>/tasks/statistics', (context,id,) => buildApiAdminUsers$idTasksStatisticsHandler(id,)(context))
    ..mount('/api/admin/users/<id>/tasks', (context,id,) => buildApiAdminUsers$idTasksHandler(id,)(context))
    ..mount('/api/admin/users/<id>', (context,id,) => buildApiAdminUsers$idHandler(id,)(context))
    ..mount('/api/admin/users', (context) => buildApiAdminUsersHandler()(context))
    ..mount('/api/auth/login', (context) => buildApiAuthLoginHandler()(context))
    ..mount('/api/auth/register', (context) => buildApiAuthRegisterHandler()(context))
    ..mount('/api/employee/attachments', (context) => buildApiEmployeeAttachmentsHandler()(context))
    ..mount('/api/employee/comments', (context) => buildApiEmployeeCommentsHandler()(context))
    ..mount('/api/employee/evaluations', (context) => buildApiEmployeeEvaluationsHandler()(context))
    ..mount('/api/employee/notifications', (context) => buildApiEmployeeNotificationsHandler()(context))
    ..mount('/api/employee/penalties', (context) => buildApiEmployeePenaltiesHandler()(context))
    ..mount('/api/employee/project_memberships', (context) => buildApiEmployeeProjectMembershipsHandler()(context))
    ..mount('/api/employee/projects', (context) => buildApiEmployeeProjectsHandler()(context))
    ..mount('/api/employee/task_details', (context) => buildApiEmployeeTaskDetailsHandler()(context))
    ..mount('/api/employee/tasks', (context) => buildApiEmployeeTasksHandler()(context))
    ..mount('/api/manager/projects', (context) => buildApiManagerProjectsHandler()(context))
    ..mount('/api/tasks/attachments', (context) => buildApiTasksAttachmentsHandler()(context))
    ..mount('/api/user', (context) => buildApiUserHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildApiAdminUsers$idTasksCountHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_users_$id_tasks_count_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminUsers$idTasksStatisticsHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_users_$id_tasks_statistics_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminUsers$idTasksHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_users_$id_tasks_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminUsers$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/status', (context) => api_admin_users_$id_status.onRequest(context,id,))..all('/', (context) => api_admin_users_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminUsersHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_users_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAuthLoginHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_auth_login_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAuthRegisterHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_auth_register_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeAttachmentsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_attachments_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeCommentsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_comments_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeEvaluationsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_evaluations_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeNotificationsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_notifications_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeePenaltiesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_penalties_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeProjectMembershipsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_project_memberships_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeProjectsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_projects_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeTaskDetailsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_task_details_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiEmployeeTasksHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_employee_tasks_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiManagerProjectsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_manager_projects_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiTasksAttachmentsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_tasks_attachments_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiUserHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_user_index.onRequest(context,));
  return pipeline.addHandler(router);
}

