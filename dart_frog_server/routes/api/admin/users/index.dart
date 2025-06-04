import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:crypto/crypto.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../../../lib/services/database_service.dart';
import '../../../../lib/utils/json_utils.dart';

/// Handler cho API quản lý người dùng của Admin
///
/// GET /api/admin/users - Lấy danh sách người dùng
/// GET /api/admin/users?status=active|inactive - Lọc người dùng theo trạng thái
/// GET /api/admin/users?search=query - Tìm kiếm người dùng
/// POST /api/admin/users - Tạo người dùng mới
/// PUT /api/admin/users/:id - Cập nhật thông tin người dùng
/// PATCH /api/admin/users/:id/status - Cập nhật trạng thái người dùng (khóa/mở khóa)
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
      // Lấy các tham số query
      final queryParams = context.request.uri.queryParameters;
      final status = queryParams['status'];
      final search = queryParams['search'];
      
      // Lấy tham số phân trang
      final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
      final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;
      final offset = (page - 1) * limit;
      
      // Xây dựng câu truy vấn SQL dựa trên các tham số
      var query = 'SELECT * FROM users';
      final params = <String, dynamic>{};
      
      // Thêm điều kiện lọc
      final conditions = <String>[];
      
      if (status != null && status.isNotEmpty) {
        conditions.add('is_active = @is_active');
        params['is_active'] = status == 'active';
        print('API: Filtering by status: $status, is_active: ${status == "active"}');
      } else {
        print('API: No status filter applied');
      }
      
      if (search != null && search.isNotEmpty) {
        conditions.add('(full_name ILIKE @search OR email ILIKE @search OR username ILIKE @search OR CAST(id AS TEXT) ILIKE @search)');
        params['search'] = '%$search%';
      }
      
      // Thêm điều kiện WHERE nếu có
      if (conditions.isNotEmpty) {
        query += ' WHERE ' + conditions.join(' AND ');
      }
      
      // Thêm sắp xếp
      query += ' ORDER BY created_at DESC';
      
      // Thêm phân trang
      query += ' LIMIT @limit OFFSET @offset';
      params['limit'] = limit;
      params['offset'] = offset;
      
      // Thực hiện truy vấn
      final users = await db.query(query, params);
      
      // Chuyển đổi DateTime thành chuỗi trước khi trả về JSON
      final jsonUsers = JsonUtils.convertListToJson(users);
      
      // Trả về dữ liệu đúng định dạng mà frontend mong đợi
      return Response.json(body: jsonUsers);

    case HttpMethod.post:
      try {
        // Tạo người dùng mới
        final data = await context.request.json() as Map<String, dynamic>;

        // Kiểm tra dữ liệu đầu vào
        final requiredFields = [
          'email',
          'username',
          'password',
          'full_name',
          'role'
        ];
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

        // Mã hóa mật khẩu trước khi lưu vào database sử dụng bcrypt
        final passwordHash = BCrypt.hashpw(data['password'], BCrypt.gensalt());

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
            'role': data['role'],
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
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

    case HttpMethod.put:
      try {
        // Lấy ID người dùng từ path
        final userId = int.tryParse(context.request.uri.path.split('/').last);
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
        
        // Xây dựng câu truy vấn cập nhật
        final updateFields = <String>[];
        final updateParams = <String, dynamic>{'id': userId};
        
        // Các trường có thể cập nhật
        final allowedFields = [
          'email',
          'username',
          'full_name',
          'role',
        ];
        
        for (final field in allowedFields) {
          if (data.containsKey(field) && data[field] != null) {
            updateFields.add('$field = @$field');
            updateParams[field] = data[field];
          }
        }
        
        // Cập nhật mật khẩu nếu có
        if (data.containsKey('password') && data['password'] != null) {
          updateFields.add('password = @password');
          updateParams['password'] = BCrypt.hashpw(data['password'], BCrypt.gensalt());
        }
        
        // Thêm thời gian cập nhật
        updateFields.add('updated_at = @updated_at');
        updateParams['updated_at'] = DateTime.now().toIso8601String();
        
        if (updateFields.isEmpty) {
          return Response.json(
            body: {'error': 'No fields to update'},
            statusCode: HttpStatus.badRequest,
          );
        }
        
        // Thực hiện cập nhật
        await db.execute(
          'UPDATE users SET ${updateFields.join(', ')} WHERE id = @id',
          updateParams,
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
      
    case HttpMethod.patch:
      try {
        // Kiểm tra xem có phải là endpoint cập nhật trạng thái không
        final pathSegments = context.request.uri.path.split('/');
        if (pathSegments.length >= 2 && pathSegments[pathSegments.length - 1] == 'status') {
          // Lấy ID người dùng
          final userId = int.tryParse(pathSegments[pathSegments.length - 2]);
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
        }
        
        return Response(statusCode: HttpStatus.notFound);
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
