import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/database_service.dart';
import '../../../lib/utils/json_utils.dart';

/// Handler cho API lấy thông tin người dùng hiện tại
///
/// GET /api/user - Trả về thông tin của user đã đăng nhập (tạm giả lập user_id = 3)
Future<Response> onRequest(RequestContext context) async {
  // Lấy instance của DatabaseService từ context (đã đăng ký provider)
  final db = context.read<DatabaseService>();

  // Kiểm tra quyền employee (trong thực tế sẽ lấy từ JWT token)
  // final userId = context.read<UserID>();

  // TODO: Lấy user_id thật từ token JWT (hiện tại giả lập user_id = 3)
  final userId = 4;

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Truy vấn thông tin người dùng theo userId
        final results = await db.query(
          'SELECT * FROM users WHERE id = @userId',
          {'userId': userId},
        );

        if (results.isEmpty) {
          return Response.json(
            body: {'error': 'User not found'},
            statusCode: HttpStatus.notFound,
          );
        }

        // Chuyển user từ Map thành JSON hợp lệ (format datetime nếu cần)
        final jsonUsers = JsonUtils.convertListToJson(results);
        return Response.json(body: jsonUsers);
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
