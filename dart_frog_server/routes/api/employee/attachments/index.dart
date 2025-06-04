import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// API trả về danh sách các thành viên của 1 dự án
///
/// GET /api/employee/attachments?project_id
Future<Response> onRequest(RequestContext context) async {
  final db = context.read<DatabaseService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy project_id từ query parameters
        // Ví dụ: /api/employee/attachments?project_id=1
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

        // Lấy tất cả attachments theo project_id
        final attachments = await db.query(
          '''
          SELECT a.*
          FROM attachments a
          JOIN projects p ON a.project_id = p.id
          WHERE p.id = @projectId
          ''',
          {'projectId': projectId},
        );

        final jsonData = JsonUtils.convertListToJson(attachments);
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
