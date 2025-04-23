import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service để gọi API từ Dart Frog server
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;
  
  final String baseUrl = 'http://localhost:8080/api';
  
  ApiService._internal();
  
  /// Lấy danh sách người dùng
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/users'));
    if (response.statusCode == 200) {
      // In ra dữ liệu trả về để debug
      print('Response body: ${response.body}');
      
      // Xử lý dữ liệu trả về
      final data = json.decode(response.body);
      
      // Kiểm tra xem dữ liệu trả về có phải là danh sách không
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else if (data is Map<String, dynamic>) {
        // Nếu dữ liệu trả về là một đối tượng, kiểm tra xem có trường data không
        if (data.containsKey('data') && data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else {
          // Nếu không có trường data, trả về một danh sách chứa đối tượng này
          return [data];
        }
      }
      
      // Trường hợp không xử lý được, trả về danh sách rỗng
      print('Unexpected response format: $data');
      return [];
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
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
      return json.decode(response.body);
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
}
