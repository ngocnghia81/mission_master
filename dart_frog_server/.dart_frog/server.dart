// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/api/user/index.dart' as api_user_index;
import '../routes/api/tasks/attachments/index.dart' as api_tasks_attachments_index;
import '../routes/api/manager/projects/index.dart' as api_manager_projects_index;
import '../routes/api/employee/tasks/index.dart' as api_employee_tasks_index;
import '../routes/api/employee/projects/index.dart' as api_employee_projects_index;
import '../routes/api/employee/project_memberships/index.dart' as api_employee_project_memberships_index;
import '../routes/api/auth/register/index.dart' as api_auth_register_index;
import '../routes/api/auth/login/index.dart' as api_auth_login_index;
import '../routes/api/admin/users/index.dart' as api_admin_users_index;

import '../routes/_middleware.dart' as middleware;

void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/api/admin/users', (context) => buildApiAdminUsersHandler()(context))
    ..mount('/api/auth/login', (context) => buildApiAuthLoginHandler()(context))
    ..mount('/api/auth/register', (context) => buildApiAuthRegisterHandler()(context))
    ..mount('/api/employee/project_memberships', (context) => buildApiEmployeeProjectMembershipsHandler()(context))
    ..mount('/api/employee/projects', (context) => buildApiEmployeeProjectsHandler()(context))
    ..mount('/api/employee/tasks', (context) => buildApiEmployeeTasksHandler()(context))
    ..mount('/api/manager/projects', (context) => buildApiManagerProjectsHandler()(context))
    ..mount('/api/tasks/attachments', (context) => buildApiTasksAttachmentsHandler()(context))
    ..mount('/api/user', (context) => buildApiUserHandler()(context));
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

