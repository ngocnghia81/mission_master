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

    // Nếu có yêu cầu cụ thể về trạng thái
    if (status != null && status.isNotEmpty) {
      // Xây dựng câu truy vấn SQL dựa trên tham số status
      final sql = '''
        SELECT COUNT(*) as count 
        FROM tasks t
        JOIN project_memberships pm ON t.membership_id = pm.id
        WHERE pm.user_id = @user_id AND t.status = @status
      ''';

      final params = <String, dynamic>{
        'user_id': userId,
        'status': status.toString(),
      };

      // Thực hiện truy vấn
      final result = await db.queryOne(sql, params);
      return Response.json(body: {'count': result?['count'] ?? 0});
    } else {
      // Nếu không có yêu cầu cụ thể, trả về thống kê tổng hợp
      final sql = '''
        SELECT 
          SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) as completed_count,
          SUM(CASE WHEN t.status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_count,
          SUM(CASE WHEN t.status = 'overdue' THEN 1 ELSE 0 END) as overdue_count,
          SUM(CASE WHEN t.status = 'not_assigned' THEN 1 ELSE 0 END) as not_assigned_count,
          COUNT(*) as total_count
        FROM tasks t
        JOIN project_memberships pm ON t.membership_id = pm.id
        WHERE pm.user_id = @user_id
      ''';

      final result = await db.queryOne(sql, {'user_id': userId});
      
      if (result == null) {
        return Response.json(body: {
          'completed_count': 0,
          'in_progress_count': 0,
          'overdue_count': 0,
          'not_assigned_count': 0,
          'total_count': 0,
        });
      }
      
      return Response.json(body: {
        'completed_count': result['completed_count'] ?? 0,
        'in_progress_count': result['in_progress_count'] ?? 0,
        'overdue_count': result['overdue_count'] ?? 0,
        'not_assigned_count': result['not_assigned_count'] ?? 0,
        'total_count': result['total_count'] ?? 0,
      });
    }
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
