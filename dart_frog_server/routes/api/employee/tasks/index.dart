import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API quản lý nhiệm vụ của Employee
///
/// GET /api/employee/tasks?employee_id=4 - Lấy danh sách nhiệm vụ được giao
Future<Response> onRequest(RequestContext context) async {
  final db = context.read<DatabaseService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        final employeeIdStr =
            context.request.uri.queryParameters['employee_id'];
        final projectIdStr = context.request.uri.queryParameters['project_id'];

        // Kiểm tra nếu có project_id thì lấy nhiệm vụ theo project
        if (projectIdStr != null) {
          // Truy vấn theo project_id
          final projectId = int.tryParse(projectIdStr);
          if (projectId == null) {
            return Response.json(
              body: {'error': 'Invalid project_id'},
              statusCode: HttpStatus.badRequest,
            );
          }

          final tasks = await db.query(
            '''
            SELECT t.*, t.start_date, t.due_days
            FROM tasks t
            JOIN project_memberships pm ON t.membership_id = pm.id
            JOIN projects p ON pm.project_id = p.id
            WHERE p.id = @projectId
            ''',
            {'projectId': projectId},
          );

          // Tính toán ngày hoàn thành
          for (final task in tasks) {
            if (task['completed_date'] == null) {
              final DateTime? startDate = task['start_date'] as DateTime?;
              final int dueDays = task['due_days'] as int? ?? 0;
              if (startDate != null) {
                final computedDate = startDate.add(Duration(days: dueDays));
                task['completed_date'] = computedDate.toIso8601String();
              }
            }
          }

          final jsonTasks = JsonUtils.convertListToJson(tasks);
          return Response.json(body: jsonTasks);
        }

        if (employeeIdStr == null) {
          return Response.json(
            body: {'error': 'Missing employee_id parameter'},
            statusCode: HttpStatus.badRequest,
          );
        } else {
          // Kiểm tra nếu employee_id là rỗng
          if (employeeIdStr == null) {
            return Response.json(
              body: {'error': 'Invalid employee_id'},
              statusCode: HttpStatus.badRequest,
            );
          } else {
            final employeeId = int.tryParse(employeeIdStr);

            // Lấy danh sách nhiệm vụ + ngày bắt đầu + số ngày hết hạn
            final tasks = await db.query(
              '''
              SELECT t.*, t.start_date, t.due_days
              FROM tasks t
              JOIN project_memberships pm ON t.membership_id = pm.id
              WHERE pm.user_id = @employeeId
              ''',
              {'employeeId': employeeId},
            );

            // Tính toán completed_date nếu đang null
            for (final task in tasks) {
              if (task['completed_date'] == null) {
                final DateTime? startDate = task['start_date'] as DateTime?;
                final int dueDays = task['due_days'] as int? ?? 0;

                if (startDate != null) {
                  final computedDate = startDate.add(Duration(days: dueDays));
                  task['completed_date'] = computedDate.toIso8601String();
                }
              }
            }

            final jsonTasks = JsonUtils.convertListToJson(tasks);
            return Response.json(body: jsonTasks);
          }
        }
      } catch (e) {
        return Response.json(
          body: {'error': 'Internal server error: ${e.toString()}'},
          statusCode: HttpStatus.internalServerError,
        );
      }

    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
