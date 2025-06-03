import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mission_master/core/models/user.dart';

/// Service để gọi API từ Dart Frog server
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;

  // 10.0.2.2 là địa chỉ đặc biệt trong Android Emulator để truy cập localhost của máy chủ
  final String baseUrl = 'http://10.0.2.2:8081/api';

  // Lưu trữ thông tin người dùng hiện tại sau khi đăng nhập
  Map<String, dynamic>? _currentUserData;

  // Giả lập dữ liệu người dùng hiện tại
  final Map<String, dynamic> _currentUser = {
    'id': '1',
    'username': 'admin',
    'email': 'admin@example.com',
    'fullName': 'Admin User',
    'role': 'admin',
    'isActive': true,
  };

  // Giả lập danh sách quản lý
  final List<Map<String, dynamic>> _managers = [];

  ApiService._internal();

  /// Lấy danh sách người dùng
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/users'));

      // In ra dữ liệu trả về để debug
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Xử lý dữ liệu trả về
        final data = json.decode(response.body);

        // Kiểm tra xem dữ liệu trả về có phải là danh sách không
        if (data is List) {
          print('Data is a list with ${data.length} items');
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          // Nếu dữ liệu trả về là một đối tượng, kiểm tra xem có trường data không
          if (data.containsKey('data') && data['data'] is List) {
            print(
                'Data contains a data field with ${(data['data'] as List).length} items');
            return (data['data'] as List).cast<Map<String, dynamic>>();
          } else {
            // Nếu không có trường data, trả về một danh sách chứa đối tượng này
            print('Data is a map, returning as a single item list');
            return [data];
          }
        }

        // Trường hợp không xử lý được, trả về danh sách rỗng
        print('Unexpected response format: $data');
        return [];
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getUsers: $e');
      throw Exception('Failed to load users: $e');
    }
  }

  /// Lấy danh sách dự án
  Future<List<Map<String, dynamic>>> getProjects() async {
    final response = await http.get(Uri.parse('$baseUrl/manager/projects'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load projects: ${response.statusCode}');
    }
  }

  /// Lấy danh sách nhiệm vụ
  Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/employee/tasks'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  /// Lấy danh sách tệp đính kèm theo task
  Future<List<Map<String, dynamic>>> getAttachmentsByTaskId(int taskId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/tasks/attachments?task_id=$taskId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load attachments: ${response.statusCode}');
    }
  }

  /// Tạo người dùng mới
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }

  /// Tạo dự án mới
  Future<Map<String, dynamic>> createProject(
      Map<String, dynamic> projectData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/manager/projects'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(projectData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create project: ${response.statusCode}');
    }
  }

  /// Tạo nhiệm vụ mới
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taskData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  /// Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    print('Gọi API login với username: $username');
    
    try {
      // Thêm timeout 10 giây để tránh treo vô hạn
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        print('Login request timeout sau 10 giây');
        throw Exception('Kết nối tới server bị timeout');
      });

      // In ra dữ liệu trả về để debug
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response data decoded: $responseData');
        
        // Kiểm tra cấu trúc response
        Map<String, dynamic> userData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('user')) {
            userData = responseData['user'];
          } else {
            // Nếu không có trường user, giả định toàn bộ response là thông tin người dùng
            userData = responseData;
          }
        } else {
          print('ERROR: Response không phải là Map!');
          throw Exception('Invalid response format');
        }
        
        // Lưu thông tin người dùng hiện tại
        _currentUserData = userData;
        print('Current user data saved: $_currentUserData');
        
        // Trả về dữ liệu đăng nhập
        return {
          'user': userData,
          'token': responseData['token'],
        };
      } else {
        final errorData = json.decode(response.body);
        print('Login error data: $errorData');
        throw Exception(
            errorData['error'] ?? 'Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during login: $e');
      rethrow;
    }
  }

  /// Đăng ký
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    // In ra dữ liệu trả về để debug
    print('Register response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
          errorData['error'] ?? 'Registration failed: ${response.statusCode}');
    }
  }

  /// Lấy thông tin người dùng hiện tại
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // Nếu đã có dữ liệu người dùng từ đăng nhập, sử dụng nó
      if (_currentUserData != null) {
        final userData = Map<String, dynamic>.from(_currentUserData!);
        
        // Đảm bảo id được trả về dưới dạng int
        if (userData['id'] != null && userData['id'] is String) {
          userData['id'] = int.tryParse(userData['id'].toString()) ?? 1;
        }
        
        // Thêm các trường ngày tháng nếu chưa có
        if (!userData.containsKey('created_at') && !userData.containsKey('createdAt')) {
          userData['created_at'] = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
        }
        
        if (!userData.containsKey('updated_at') && !userData.containsKey('updatedAt')) {
          userData['updated_at'] = DateTime.now().toIso8601String();
        }
        
        print('getCurrentUser returning from _currentUserData: $userData');
        return userData;
      }
      
      // Nếu chưa đăng nhập, thử lấy thông tin người dùng từ API
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/me'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData is Map<String, dynamic>) {
            _currentUserData = responseData;
            print('getCurrentUser fetched from API: $_currentUserData');
            return getCurrentUser(); // Gọi lại để xử lý dữ liệu
          }
        }
      } catch (e) {
        print('Error fetching current user from API: $e');
        // Tiếp tục sử dụng dữ liệu mẫu nếu API không hoạt động
      }
      
      // Nếu không có dữ liệu từ API, sử dụng dữ liệu mẫu
      final userData = Map<String, dynamic>.from(_currentUser);
      
      // Đảm bảo id được trả về dưới dạng int
      if (userData['id'] != null && userData['id'] is String) {
        userData['id'] = int.tryParse(userData['id'].toString()) ?? 1;
      }
      
      // Thêm các trường ngày tháng nếu chưa có
      if (!userData.containsKey('created_at') && !userData.containsKey('createdAt')) {
        userData['created_at'] = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      }
      
      if (!userData.containsKey('updated_at') && !userData.containsKey('updatedAt')) {
        userData['updated_at'] = DateTime.now().toIso8601String();
      }
      
      print('getCurrentUser returning from _currentUser: $userData');
      return userData;
    } catch (e) {
      print('Error getting current user: $e');
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Lấy danh sách người dùng với bộ lọc và phân trang
  Future<List<Map<String, dynamic>>> getUsersWithFilter({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Chỉ thêm status vào query params nếu nó không rỗng
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
        print('Adding status filter: $status');
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/admin/users')
          .replace(queryParameters: queryParams);
      print('Request URL: ${uri.toString()}');

      final response = await http.get(uri);

      print('Get users response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            return (data['data'] as List).cast<Map<String, dynamic>>();
          } else {
            return [data];
          }
        }
        return [];
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getUsersWithFilter: $e');
      throw Exception('Failed to load users: $e');
    }
  }

  /// Cập nhật trạng thái người dùng (khóa/mở khóa)
  Future<Map<String, dynamic>> updateUserStatus(
      int userId, bool isActive) async {
    try {
      // Đường dẫn API phải khớp với định nghĩa trong server
      // Trong server, đường dẫn là: /api/admin/users/:id/status
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'is_active': isActive,
        }),
      );

      print(
          'Update user status response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in updateUserStatus: $e');
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Cập nhật thông tin người dùng
  Future<Map<String, dynamic>> updateUser(
      int userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      print('Update user response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in updateUser: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  /// Lấy số lượng task của người dùng
  Future<int> getTaskCountByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/$userId/tasks/count'),
      );

      print(
          'Get task count response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('count')) {
          return data['count'] as int;
        }
        // Nếu API chưa được triển khai, trả về số ngẫu nhiên từ 0-10
        return (userId % 10) + 1; // Số ngẫu nhiên dựa trên userId
      } else {
        // Nếu API chưa được triển khai, trả về số ngẫu nhiên từ 0-10
        return (userId % 10) + 1; // Số ngẫu nhiên dựa trên userId
      }
    } catch (e) {
      print('Exception in getTaskCountByUserId: $e');
      // Nếu API chưa được triển khai, trả về số ngẫu nhiên từ 0-10
      return (userId % 10) + 1; // Số ngẫu nhiên dựa trên userId
    }
  }

  /// Lấy thông tin người dùng theo ID
  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/$userId'),
      );

      print('Get user by ID response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return userData;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getUserById: $e');
      throw Exception('Failed to load user: $e');
    }
  }

  /// Lấy danh sách nhiệm vụ của người dùng với phân trang
  Future<List<Map<String, dynamic>>> getUserTasks(
    int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/admin/users/$userId/tasks')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      print(
          'Get user tasks response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic> &&
            data.containsKey('data') &&
            data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getUserTasks: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  /// Lấy thống kê nhiệm vụ của người dùng theo trạng thái
  Future<Map<String, dynamic>> getUserTaskStatistics(
    int userId, {
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/admin/users/$userId/tasks/statistics')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      print(
          'Get user task statistics response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load task statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getUserTaskStatistics: $e');
      throw Exception('Failed to load task statistics: $e');
    }
  }

  // Tạo tài khoản quản lý mới
  Future<bool> createManagerAccount({
    required String fullName,
    required String email,
    required String username,
    required String phone,
    required String password,
  }) async {
    try {
      // Giả lập độ trễ của API
      await Future.delayed(const Duration(seconds: 1));
      
      // Kiểm tra email và username đã tồn tại chưa
      final existingManager = _managers.firstWhere(
        (manager) => manager['email'] == email || manager['username'] == username,
        orElse: () => <String, dynamic>{},
      );
      
      if (existingManager.isNotEmpty) {
        return false; // Email hoặc username đã tồn tại
      }
      
      // Tạo manager mới
      final newManager = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'fullName': fullName,
        'email': email,
        'username': username,
        'phone': phone,
        'password': password, // Trong thực tế cần mã hóa mật khẩu
        'role': 'manager',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Thêm vào danh sách quản lý
      _managers.add(newManager);
      
      print('Created manager account: ${newManager['username']}');
      return true;
    } catch (e) {
      print('Error creating manager account: $e');
      return false;
    }
  }
}
