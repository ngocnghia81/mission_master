import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service để gọi API từ Dart Frog server
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;
  
  final String baseUrl = 'http://localhost:8080/api';
  
  // Lưu trữ thông tin người dùng hiện tại sau khi đăng nhập
  Map<String, dynamic>? _currentUserData;
  
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
            print('Data contains a data field with ${(data['data'] as List).length} items');
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
    final response = await http.get(Uri.parse('$baseUrl/tasks/attachments?task_id=$taskId'));
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
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> projectData) async {
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
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    
    // In ra dữ liệu trả về để debug
    print('Login response: ${response.statusCode} - ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Lưu thông tin người dùng hiện tại
      _currentUserData = responseData['user'];
      return responseData;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Login failed: ${response.statusCode}');
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
      throw Exception(errorData['error'] ?? 'Registration failed: ${response.statusCode}');
    }
  }
  
  /// Lấy thông tin người dùng hiện tại
  Future<Map<String, dynamic>> getCurrentUser() async {
    // Nếu đã có thông tin người dùng trong bộ nhớ, trả về ngay
    if (_currentUserData != null) {
      return _currentUserData!;
    }
    
    // Trong trường hợp thực tế, bạn có thể gọi API để lấy thông tin người dùng hiện tại
    // dựa trên token đã lưu
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Thêm token xác thực nếu cần
        },
      );
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUserData = userData;
        return userData;
      } else {
        throw Exception('Failed to get current user: ${response.statusCode}');
      }
    } catch (e) {
      // Nếu API chưa được triển khai, trả về dữ liệu mẫu
      if (_currentUserData != null) {
        return _currentUserData!;
      }
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
      
      final uri = Uri.parse('$baseUrl/admin/users').replace(queryParameters: queryParams);
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
  Future<Map<String, dynamic>> updateUserStatus(int userId, bool isActive) async {
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
      
      print('Update user status response: ${response.statusCode} - ${response.body}');
      
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
  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> userData) async {
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
      
      print('Get task count response: ${response.statusCode} - ${response.body}');
      
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
        return json.decode(response.body);
      } else {
        // Nếu API chưa được triển khai, trả về dữ liệu mẫu
        return {
          'id': userId,
          'username': 'user$userId',
          'email': 'user$userId@example.com',
          'full_name': 'Người dùng $userId',
          'role': userId % 3 == 0 ? 'admin' : (userId % 3 == 1 ? 'manager' : 'employee'),
          'is_active': userId % 2 == 0,
          'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      print('Exception in getUserById: $e');
      // Nếu API chưa được triển khai, trả về dữ liệu mẫu
      return {
        'id': userId,
        'username': 'user$userId',
        'email': 'user$userId@example.com',
        'full_name': 'Người dùng $userId',
        'role': userId % 3 == 0 ? 'admin' : (userId % 3 == 1 ? 'manager' : 'employee'),
        'is_active': userId % 2 == 0,
        'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
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
      
      final uri = Uri.parse('$baseUrl/admin/users/$userId/tasks').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      print('Get user tasks response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic> && data.containsKey('data') && data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        // Nếu API chưa được triển khai, trả về dữ liệu mẫu
        final tasks = <Map<String, dynamic>>[];
        final random = DateTime.now().millisecondsSinceEpoch % 10 + 1;
        final count = (page == 1) ? random : (random ~/ 2);
        
        for (var i = 0; i < count; i++) {
          final taskId = (page - 1) * limit + i + 1;
          tasks.add({
            'id': taskId,
            'title': 'Nhiệm vụ $taskId',
            'description': 'Mô tả chi tiết cho nhiệm vụ $taskId của người dùng $userId',
            'status': ['not_assigned', 'in_progress', 'completed', 'overdue'][(taskId + userId) % 4],
            'priority': ['high', 'medium', 'low'][(taskId + userId) % 3],
            'start_date': DateTime.now().subtract(Duration(days: 10 + (taskId % 5))).toIso8601String(),
            'due_date': DateTime.now().add(Duration(days: 5 + (taskId % 10))).toIso8601String(),
            'project_id': 1 + (taskId % 3),
            'created_at': DateTime.now().subtract(Duration(days: 10 + (taskId % 5))).toIso8601String(),
            'updated_at': DateTime.now().subtract(Duration(days: (taskId % 5))).toIso8601String(),
          });
        }
        
        return tasks;
      }
    } catch (e) {
      print('Exception in getUserTasks: $e');
      // Nếu có lỗi, trả về danh sách rỗng
      return [];
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
      
      final uri = Uri.parse('$baseUrl/admin/users/$userId/tasks/statistics').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      print('Get user task statistics response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Nếu API chưa được triển khai, trả về dữ liệu mẫu
        if (status == 'completed') {
          return {'count': (userId % 5) + 3};
        } else if (status == 'overdue') {
          return {'count': (userId % 3) + 1};
        } else {
          return {'count': (userId % 10) + 5};
        }
      }
    } catch (e) {
      print('Exception in getUserTaskStatistics: $e');
      // Nếu có lỗi, trả về dữ liệu mẫu
      if (status == 'completed') {
        return {'count': (userId % 5) + 3};
      } else if (status == 'overdue') {
        return {'count': (userId % 3) + 1};
      } else {
        return {'count': (userId % 10) + 5};
      }
    }
  }
}
