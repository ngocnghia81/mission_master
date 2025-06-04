import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// API trả về danh sách các dự án của 1 nhân viên
///
/// GET /api/employee/projects
Future<Response> onRequest(RequestContext context) async {
  final db = context.read<DatabaseService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy emplyee_id từ query parameters
        // Ví dụ: /api/employee/projects?employee_id=4
        final employeeIdStr =
            context.request.uri.queryParameters['employee_id'];
        if (employeeIdStr == null) {
          return Response.json(
            body: {'error': 'Missing employee_id parameter'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Chuyển đổi employee_id từ String sang int
        final employeeId = int.tryParse(employeeIdStr);
        if (employeeId == null) {
          return Response.json(
            body: {'error': 'Invalid employee_id'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Lấy tất cả project của 1 nhân viên
        final memberProjects = await db.query(
          '''
          SELECT p.*
          FROM project_memberships pm
          JOIN projects p ON pm.project_id = p.id
          WHERE pm.user_id = @employeeId
          ''',
          {'employeeId': employeeId},
        );

        final jsonData = JsonUtils.convertListToJson(memberProjects);
        return Response.json(body: jsonData);
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
