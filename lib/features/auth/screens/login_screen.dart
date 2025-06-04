import 'package:flutter/material.dart';
import 'package:mission_master/features/auth/screens/register_screen.dart';
import 'package:mission_master/features/home/screens/calendar_task_screen.dart';
import 'package:mission_master/services/api_service.dart';
import 'package:mission_master/core/models/user.dart';

//providers
import 'package:provider/provider.dart';
import 'package:mission_master/emp_providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Sử dụng API đăng nhập mới
        final api = ApiService.instance;
        print('Đang gọi API login với username: ${_usernameController.text}');
        final response = await api.login(
          _usernameController.text,
          _passwordController.text,
        );

        // Xử lý kết quả đăng nhập
        print('Response đầy đủ: $response');
        final userData = response['user'];
        print('Login successful: $userData');
        
        if (userData == null) {
          setState(() {
            _errorMessage = 'Không nhận được dữ liệu người dùng từ server';
            _isLoading = false;
          });
          return;
        }
        
        try {
          // Tạo đối tượng User từ dữ liệu trả về
          print('Đang tạo User từ JSON: $userData');
          final user = User.fromJson(userData);
          print('User đã tạo: ${user.username}, role: ${user.role}');
          
          // Lưu thông tin người dùng vào bộ nhớ tạm thời (có thể sử dụng SharedPreferences)
          // TODO: Lưu thông tin người dùng để sử dụng trong các màn hình khác

          // Chuyển hướng dựa trên vai trò của người dùng
          if (user.isAdmin) {
            print('User có vai trò: ${user.role}');
            print('isAdmin = ${user.isAdmin}, kiểm tra: ${user.role == "admin"}');
            print('Chuyển hướng tới trang admin: /admin/dashboard');
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
          } else if (user.isManager) {
            print('User có vai trò: ${user.role}');
            print('isManager = ${user.isManager}, kiểm tra: ${user.role == "manager"}');
            print('Chuyển hướng tới trang manager: /projects');
            Navigator.pushReplacementNamed(context, '/projects');
          } else {
            print('User có vai trò: ${user.role}');
            print('isEmployee = ${user.isEmployee}, kiểm tra: ${user.role == "employee"}');
            print('Chuyển hướng tới trang employee: /home');
            Navigator.pushReplacementNamed(context, '/home-employee');
          }
        } catch (userError) {
          print('Error creating user object: $userError');
          setState(() {
            _errorMessage = 'Lỗi xử lý dữ liệu người dùng: $userError';
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Login error: $e');
        setState(() {
          _errorMessage = 'Lỗi đăng nhập: ${e.toString().contains('timeout') ? 'Kết nối server bị timeout' : e}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003440),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/login_illustration.png',
                      height: 150),
                  const SizedBox(height: 20),
                  Text(
                    'Missions',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_errorMessage != null && _errorMessage!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.red.withOpacity(0.3),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Tài khoản hoặc Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tài khoản hoặc email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator(color: Color(0xFF00BCD4))
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00BCD4),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Chưa có tài khoản? ',
                        style: TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.underline),
                        children: [
                          TextSpan(
                            text: 'Đăng ký',
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.bold), // Chỉ in đậm "Đăng ký"
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white, fontSize: 16),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        errorStyle: TextStyle(color: Colors.redAccent, fontSize: 12),
        contentPadding: EdgeInsets.only(bottom: 8),
      ),
    );
  }
}