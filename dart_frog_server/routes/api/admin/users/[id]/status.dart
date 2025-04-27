import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../../lib/services/database_service.dart';
import '../../../../../lib/utils/json_utils.dart';

/// Handler cho API cập nhật trạng thái người dùng (khóa/mở khóa)
/// PATCH /api/admin/users/:id/status
Future<Response> onRequest(RequestContext context, String id) async {
  // Chỉ xử lý phương thức PATCH
  if (context.request.method != HttpMethod.patch) {
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
    
    // Lấy dữ liệu cập nhật
    final data = await context.request.json() as Map<String, dynamic>;
    
    if (!data.containsKey('is_active')) {
      return Response.json(
        body: {'error': 'Missing is_active field'},
        statusCode: HttpStatus.badRequest,
      );
    }
    
    // Cập nhật trạng thái
    await db.execute(
      'UPDATE users SET is_active = @is_active, updated_at = @updated_at WHERE id = @id',
      {
        'id': userId,
        'is_active': data['is_active'],
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
    
    // Lấy người dùng sau khi cập nhật
    final updatedUser = await db.queryOne(
      'SELECT * FROM users WHERE id = @id',
      {'id': userId},
    );
    
    // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
    final jsonUser = JsonUtils.convertMapToJson(updatedUser!);
    
    return Response.json(body: jsonUser);
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
