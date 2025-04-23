import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API quản lý dự án của Manager
///
/// GET /api/manager/projects - Lấy danh sách dự án của manager
/// POST /api/manager/projects - Tạo dự án mới
Future<Response> onRequest(RequestContext context) async {
  // Lấy DatabaseService từ provider
  final db = context.read<DatabaseService>();
  
  // Kiểm tra quyền manager (trong thực tế sẽ lấy từ JWT token)
  // final user = context.read<User>();
  // if (!user.isManager) {
  //   return Response(statusCode: HttpStatus.forbidden);
  // }
  
  // Giả sử managerId = 1 cho ví dụ
  final managerId = 1;
  
  switch (context.request.method) {
    case HttpMethod.get:
      // Lấy danh sách dự án của manager
      final projects = await db.query(
        'SELECT * FROM projects WHERE manager_id = @managerId',
        {'managerId': managerId},
      );
      // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
      final jsonProjects = JsonUtils.convertListToJson(projects);
      return Response.json(body: jsonProjects);
    
    case HttpMethod.post:
      try {
        // Tạo dự án mới
        final data = await context.request.json() as Map<String, dynamic>;
        
        // Đảm bảo manager_id là của manager hiện tại
        data['manager_id'] = managerId;
        
        // Thêm dự án mới
        final projectId = await db.insert(
          '''
          INSERT INTO projects (
            name, description, start_date, end_date, status, manager_id, 
            created_at, updated_at
          ) VALUES (
            @name, @description, @startDate, @endDate, @status, @managerId,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          )
          ''',
          {
            'name': data['name'],
            'description': data['description'],
            'startDate': data['start_date'],
            'endDate': data['end_date'],
            'status': data['status'] ?? 'not_started',
            'managerId': managerId,
          },
        );
        
        // Lấy dự án vừa tạo
        final createdProject = await db.queryOne(
          'SELECT * FROM projects WHERE id = @id',
          {'id': projectId},
        );
        
        // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
        final jsonProject = JsonUtils.convertMapToJson(createdProject!);
        
        return Response.json(
          body: jsonProject,
          statusCode: HttpStatus.created,
        );
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
