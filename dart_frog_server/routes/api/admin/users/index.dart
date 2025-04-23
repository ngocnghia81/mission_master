import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API quản lý người dùng của Admin
///
/// GET /api/admin/users - Lấy danh sách người dùng
/// POST /api/admin/users - Tạo người dùng mới
Future<Response> onRequest(RequestContext context) async {
  // Lấy DatabaseService từ provider
  final db = context.read<DatabaseService>();
  
  // Kiểm tra quyền admin (trong thực tế sẽ lấy từ JWT token)
  // final user = context.read<User>();
  // if (!user.isAdmin) {
  //   return Response(statusCode: HttpStatus.forbidden);
  // }
  
  switch (context.request.method) {
    case HttpMethod.get:
      // Lấy danh sách người dùng
      final users = await db.query('SELECT * FROM users WHERE role = @role', {'role': 'admin'});
      // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
      final jsonUsers = JsonUtils.convertListToJson(users);
      return Response.json(body: jsonUsers);
    
    case HttpMethod.post:
      try {
        // Tạo người dùng mới
        final data = await context.request.json() as Map<String, dynamic>;
        
        // Kiểm tra dữ liệu đầu vào
        final requiredFields = ['email', 'username', 'password', 'full_name', 'role'];
        for (final field in requiredFields) {
          if (!data.containsKey(field) || data[field] == null) {
            return Response.json(
              body: {'error': 'Missing required field: $field'},
              statusCode: HttpStatus.badRequest,
            );
          }
        }
        
        // Kiểm tra email và username đã tồn tại chưa
        final existingUser = await db.queryOne(
          'SELECT * FROM users WHERE email = @email OR username = @username',
          {'email': data['email'], 'username': data['username']},
        );
        
        if (existingUser != null) {
          return Response.json(
            body: {'error': 'Email or username already exists'},
            statusCode: HttpStatus.conflict,
          );
        }
        
        // Thêm người dùng mới
        final userId = await db.insert(
          '''
          INSERT INTO users (
            email, username, password, full_name, role, is_active, created_at, updated_at
          ) VALUES (
            @email, @username, @password, @fullName, @role, @isActive, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          )
          ''',
          {
            'email': data['email'],
            'username': data['username'],
            'password': data['password'], // Trong thực tế cần hash password
            'fullName': data['full_name'],
            'role': data['role'],
            'isActive': data['is_active'] ?? true,
          },
        );
        
        // Lấy người dùng vừa tạo
        final createdUser = await db.queryOne(
          'SELECT * FROM users WHERE id = @id',
          {'id': userId},
        );
        
        // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
        final jsonUser = JsonUtils.convertMapToJson(createdUser!);
        
        return Response.json(
          body: jsonUser,
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
