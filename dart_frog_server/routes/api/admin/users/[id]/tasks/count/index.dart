import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../../../../lib/services/database_service.dart';

/// Handler cho API lấy số lượng task của người dùng
/// GET /api/admin/users/:id/tasks/count
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
    
    // Đếm số lượng task của người dùng thông qua project_memberships
    final result = await db.queryOne('''
      SELECT COUNT(*) as count 
      FROM tasks t
      JOIN project_memberships pm ON t.membership_id = pm.id
      WHERE pm.user_id = @user_id
    ''', {'user_id': userId});
    
    return Response.json(body: {'count': result?['count'] ?? 0});
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
