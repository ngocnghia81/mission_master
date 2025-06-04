import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// API trả về danh sách các thành viên của 1 dự án
///
/// GET /api/employee/comments?task_id
Future<Response> onRequest(RequestContext context) async {
  final db = context.read<DatabaseService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy task_id từ query parameters
        // Ví dụ: /api/employee/comments?task_id=1
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

        // Lấy tất cả đánh giá theo task_id
        final comments = await db.query(
          '''
          SELECT c.*
          FROM comments c
          JOIN tasks t ON c.task_id = t.id
          WHERE c.task_id = @taskId
          ''',
          {'taskId': taskId},
        );

        final jsonData = JsonUtils.convertListToJson(comments);
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
