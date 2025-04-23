import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API quản lý nhiệm vụ của Employee
///
/// GET /api/employee/tasks - Lấy danh sách nhiệm vụ được giao cho employee
/// PUT /api/employee/tasks/:id/status - Cập nhật trạng thái nhiệm vụ
Future<Response> onRequest(RequestContext context) async {
  // Lấy DatabaseService từ provider
  final db = context.read<DatabaseService>();
  
  // Kiểm tra quyền employee (trong thực tế sẽ lấy từ JWT token)
  // final user = context.read<User>();
  
  // Giả sử employeeId = 3 cho ví dụ
  final employeeId = 3;
  
  switch (context.request.method) {
    case HttpMethod.get:
      try {
        // Lấy danh sách nhiệm vụ được giao cho employee
        final tasks = await db.query(
          'SELECT * FROM tasks WHERE assigned_to = @employeeId',
          {'employeeId': employeeId},
        );
        // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
        final jsonTasks = JsonUtils.convertListToJson(tasks);
        return Response.json(body: jsonTasks);
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
