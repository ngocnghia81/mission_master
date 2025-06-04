import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../../lib/services/database_service.dart';
import '../../../../../lib/utils/json_utils.dart';

/// Handler cho API lấy thông tin chi tiết người dùng
/// GET /api/admin/users/:id
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
    
    // Lấy thông tin chi tiết người dùng
    final user = await db.queryOne(
      '''
      SELECT 
        u.*,
        COUNT(pm.id) as project_count
      FROM users u
      LEFT JOIN project_memberships pm ON u.id = pm.user_id
      WHERE u.id = @id
      GROUP BY u.id
      ''',
      {'id': userId},
    );
    
    if (user == null) {
      return Response.json(
        body: {'error': 'User not found'},
        statusCode: HttpStatus.notFound,
      );
    }
    
    // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
    final jsonUser = JsonUtils.convertMapToJson(user);
    
    return Response.json(body: jsonUser);
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
} 