import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API đăng nhập
///
/// POST /api/auth/login - Đăng nhập và trả về thông tin người dùng
Future<Response> onRequest(RequestContext context) async {
  // Chỉ chấp nhận phương thức POST
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    // Lấy DatabaseService từ provider
    final db = context.read<DatabaseService>();

    // Lấy dữ liệu đăng nhập từ request
    final data = await context.request.json() as Map<String, dynamic>;

    // Kiểm tra dữ liệu đầu vào
    if (!data.containsKey('username') || !data.containsKey('password')) {
      return Response.json(
        body: {'error': 'Username and password are required'},
        statusCode: HttpStatus.badRequest,
      );
    }

    final username = data['username'] as String;
    final password = data['password'] as String;

    // Tìm người dùng theo username
    final user = await db.queryOne(
      'SELECT * FROM users WHERE username = @username OR email = @username AND is_active = true',
      {'username': username},
    );

    // Nếu không tìm thấy người dùng
    if (user == null) {
      return Response.json(
        body: {'error': 'Invalid username or password'},
        statusCode: HttpStatus.unauthorized,
      );
    }

    // Kiểm tra mật khẩu
    final passwordMatches =
        BCrypt.checkpw(password, user['password'] as String);

    if (!passwordMatches) {
      return Response.json(
        body: {'error': 'Invalid username or password'},
        statusCode: HttpStatus.unauthorized,
      );
    }

    // Loại bỏ mật khẩu trước khi trả về thông tin người dùng
    final userInfo = Map<String, dynamic>.from(user);
    userInfo.remove('password');

    // Chuyển đổi DateTime thành chuỗi
    final jsonUser = JsonUtils.convertMapToJson(userInfo);

    // Trả về thông tin người dùng
    return Response.json(
      body: {
        'user': jsonUser,
        'message': 'Login successful',
      },
      statusCode: HttpStatus.ok,
    );
  } catch (e) {
    return Response.json(
      body: {'error': 'Login failed: $e'},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
