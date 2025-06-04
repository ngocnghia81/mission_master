import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../../../lib/services/database_service.dart';
import '../../../../../../lib/utils/json_utils.dart';

/// Handler cho API lấy danh sách nhiệm vụ của người dùng
/// GET /api/admin/users/:id/tasks
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

    // Lấy tham số phân trang từ query parameters
    final queryParams = context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final limit = int.tryParse(queryParams['limit'] ?? '10') ?? 10;
    final offset = (page - 1) * limit;
    
    // Lấy danh sách nhiệm vụ của người dùng với thông tin dự án
    final tasks = await db.query('''
      SELECT 
        t.*,
        p.name as project_name,
        p.id as project_id
      FROM tasks t
      JOIN project_memberships pm ON t.membership_id = pm.id
      JOIN projects p ON pm.project_id = p.id
      WHERE pm.user_id = @user_id
      ORDER BY 
        CASE 
          WHEN t.status = 'overdue' THEN 1
          WHEN t.status = 'in_progress' THEN 2
          WHEN t.status = 'not_assigned' THEN 3
          WHEN t.status = 'completed' THEN 4
          ELSE 5
        END,
        t.due_days ASC
      LIMIT @limit OFFSET @offset
    ''', {
      'user_id': userId,
      'limit': limit,
      'offset': offset,
    });
    
    // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
    final jsonTasks = tasks.map((task) => JsonUtils.convertMapToJson(task)).toList();
    
    return Response.json(body: jsonTasks);
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
