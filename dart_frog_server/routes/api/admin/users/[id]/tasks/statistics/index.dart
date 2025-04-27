import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../../../../lib/services/database_service.dart';

/// Handler cho API lấy thống kê nhiệm vụ của người dùng
/// GET /api/admin/users/:id/tasks/statistics
Future<Response> onRequest(RequestContext context, String id) async {
  // Chỉ xử lý phương thức GET
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    // Lấy DatabaseService từ provider
    final db = context.read<DatabaseService>();

    // Chuyển đổi ID thành số
    final userId = int.tryParse(id);
    if (userId == null) {
      return Response.json(
        body: {'error': 'Invalid user ID'},
        statusCode: HttpStatus.badRequest,
      );
    }

    // Kiểm tra người dùng tồn tại
    final existingUser = await db.queryOne(
      'SELECT * FROM users WHERE id = @id',
      {'id': userId},
    );

    if (existingUser == null) {
      return Response.json(
        body: {'error': 'User not found'},
        statusCode: HttpStatus.notFound,
      );
    }

    // Lấy tham số trạng thái từ query parameters
    final queryParams = context.request.uri.queryParameters;
    final status = queryParams['status'];

    // Xây dựng câu truy vấn SQL dựa trên tham số status
    String sql = '''
      SELECT COUNT(*) as count 
      FROM tasks t
      JOIN project_memberships pm ON t.membership_id = pm.id
      WHERE pm.user_id = @user_id
    ''';

    final params = <String, dynamic>{'user_id': userId};

    // Thêm điều kiện trạng thái nếu có
    if (status != null && status.isNotEmpty) {
      sql += ' AND t.status = @status';
      // Đảm bảo status được xử lý như một chuỗi
      params['status'] = status.toString();
    }

    // Thực hiện truy vấn
    final result = await db.queryOne(sql, params);

    return Response.json(body: {'count': result?['count'] ?? 0});
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
