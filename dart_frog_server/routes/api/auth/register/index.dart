import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API đăng ký
///
/// POST /api/auth/register - Đăng ký người dùng mới
Future<Response> onRequest(RequestContext context) async {
  // Chỉ chấp nhận phương thức POST
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    // Lấy DatabaseService từ provider
    final db = context.read<DatabaseService>();
    
    // Lấy dữ liệu đăng ký từ request
    final data = await context.request.json() as Map<String, dynamic>;
    
    // Kiểm tra dữ liệu đầu vào
    final requiredFields = ['email', 'username', 'password', 'full_name'];
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
        statusCode: HttpStatus.badRequest,
      );
    }
    
    // Mã hóa mật khẩu trước khi lưu vào database
    final passwordHash = BCrypt.hashpw(data['password'], BCrypt.gensalt());
    
    // Mặc định role là 'employee' nếu không được chỉ định
    final role = data['role'] ?? 'employee';
    
    // Tạo người dùng mới
    final userId = await db.insert(
      '''
      INSERT INTO users (email, username, password, full_name, role, is_active, created_at, updated_at)
      VALUES (@email, @username, @password, @full_name, @role, @is_active, @created_at, @updated_at)
      ''',
      {
        'email': data['email'],
        'username': data['username'],
        'password': passwordHash,
        'full_name': data['full_name'],
        'role': role,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
    
    if (userId <= 0) {
      return Response.json(
        body: {'error': 'Failed to create user'},
        statusCode: HttpStatus.internalServerError,
      );
    }
    
    // Lấy thông tin người dùng vừa tạo
    final newUser = await db.queryOne(
      'SELECT * FROM users WHERE id = @id',
      {'id': userId},
    );
    
    if (newUser == null) {
      return Response.json(
        body: {'error': 'User created but could not retrieve user data'},
        statusCode: HttpStatus.internalServerError,
      );
    }
    
    // Loại bỏ mật khẩu trước khi trả về thông tin người dùng
    final userInfo = Map<String, dynamic>.from(newUser);
    userInfo.remove('password');
    
    // Chuyển đổi DateTime thành chuỗi
    final jsonUser = JsonUtils.convertMapToJson(userInfo);
    
    // Trả về thông tin người dùng
    return Response.json(
      body: {
        'user': jsonUser,
        'message': 'Registration successful',
      },
      statusCode: HttpStatus.created,
    );
  } catch (e) {
    return Response.json(
      body: {'error': 'Registration failed: $e'},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
