import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API quản lý nhiệm vụ của Employee
///
/// GET /api/employee/tasks - Lấy danh sách nhiệm vụ được giao cho employee
/// PUT /api/employee/tasks/:id/status - Cập nhật trạng thái nhiệm vụ
Future<Response> onRequest(RequestContext context) async {
  // Lấy DatabaseService từ provider
  final db = context.read<DatabaseService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy emplyee_id từ query parameters
        // Ví dụ: /api/employee/task_details?task_id=2
        final taskIdStr = context.request.uri.queryParameters['task_id'];
        if (taskIdStr == null) {
          return Response.json(
            body: {'error': 'Missing task_id parameter'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Chuyển đổi task_id từ String sang int
        final taskId = int.tryParse(taskIdStr);
        if (taskId == null) {
          return Response.json(
            body: {'error': 'Invalid task_id'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Lấy danh sách nhiệm vụ được giao cho employee thông qua project_memberships
        final task_details = await db.query(
          '''
          SELECT td.* 
          FROM task_details td
          JOIN tasks t ON t.id = td.task_id
          WHERE t.id = @taskId
          ''',
          {'taskId': taskId},
        );

        // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
        final jsonTasks = JsonUtils.convertListToJson(task_details);
        return Response.json(body: jsonTasks);
      } catch (e) {
        return Response.json(
          body: {'error': e.toString()},
          statusCode: HttpStatus.internalServerError,
        );
      }

    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
