import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// API trả về danh sách các thành viên của 1 dự án
///
/// GET /api/employee/notifications?user_id
Future<Response> onRequest(RequestContext context) async {
  final db = context.read<DatabaseService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy user_id từ query parameters
        // Ví dụ: /api/employee/notifications?user_id=1
        final userIdStr = context.request.uri.queryParameters['user_id'];
        if (userIdStr == null) {
          return Response.json(
            body: {'error': 'Missing user_id parameter'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Chuyển đổi user_id từ String sang int
        final userId = int.tryParse(userIdStr);
        if (userId == null) {
          return Response.json(
            body: {'error': 'Invalid user_id'},
            statusCode: HttpStatus.badRequest,
          );
        }

        // Lấy tất cả thông báo theo user_id
        final memberusers = await db.query(
          '''
          SELECT n.*
          FROM notifications n
          JOIN users u ON n.user_id = u.id
          WHERE u.id = @userId
          ''',
          {'userId': userId},
        );

        final jsonData = JsonUtils.convertListToJson(memberusers);
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
