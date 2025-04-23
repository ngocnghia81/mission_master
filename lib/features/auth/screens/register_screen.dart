import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mission_master/services/api_service.dart';
import 'package:mission_master/core/models/user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Mặc định chỉ là nhân viên, không cho người dùng chọn
  final String _role = 'employee';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Sử dụng API đăng ký mới
        final api = ApiService.instance;
        
        // Chuẩn bị dữ liệu đăng ký
        final userData = {
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text, // Mật khẩu sẽ được mã hóa bởi API
          'full_name': _fullNameController.text,
          'role': 'employee', // Mặc định là nhân viên
        };
        
        // Gọi API đăng ký
        final response = await api.register(userData);
        
        // In thông tin đăng ký thành công
        print('Registration successful: ${response['user']}');

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo tài khoản thành công!')),
        );

        // Đăng ký thành công, chuyển đến màn hình đăng nhập
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        setState(() {
          _errorMessage = 'Đã xảy ra lỗi: ${e.toString()}';
          _isLoading = false;
        });
        print('Registration error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003440),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20), // Thay thế khoảng cách cho nút back
                Image.asset('assets/images/login_illustration.png',
                    height: 120),
                const SizedBox(height: 20),
                Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: 26,
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
                _buildFormField(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _usernameController,
                  label: 'Tên đăng nhập',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    if (value.length < 4) {
                      return 'Tên đăng nhập phải có ít nhất 4 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _phoneController,
                  label: 'Số điện thoại (tùy chọn)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white.withOpacity(0.08),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Bạn sẽ được đăng ký với quyền Nhân viên',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.cyan)
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00BCD4),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Đăng ký',
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
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Đã có tài khoản? ',
                      style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline),
                      children: [
                        TextSpan(
                          text: 'Đăng nhập',
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
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
