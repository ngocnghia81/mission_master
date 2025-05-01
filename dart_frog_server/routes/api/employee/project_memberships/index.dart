import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// API trả về danh sách các thành viên của 1 dự án
///
/// GET /api/employee/project_memberships
Future<Response> onRequest(RequestContext context) async {
  final db = context.read<DatabaseService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy project_id từ query parameters
        // Ví dụ: /api/employee/project_memberships?project_id=1
        final projectIdStr = context.request.uri.queryParameters['project_id'];
        if (projectIdStr == null) {
          return Response.json(
            body: {'error': 'Missing project_id parameter'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Chuyển đổi project_id từ String sang int
        final projectId = int.tryParse(projectIdStr);
        if (projectId == null) {
          return Response.json(
            body: {'error': 'Invalid project_id'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Lấy tất cả thành viên theo project_id
        final memberProjects = await db.query(
          '''
          SELECT pm.*
          FROM project_memberships pm
          JOIN projects p ON pm.project_id = p.id
          WHERE p.id = @projectId
          ''',
          {'projectId': projectId},
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
