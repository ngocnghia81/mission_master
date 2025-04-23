import 'package:flutter/material.dart';
import 'package:mission_master/config/database_config.dart';
import 'package:mission_master/core/models/role.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/services/database_service.dart';
import 'package:mission_master/shared/widgets/app_bar_widget.dart';

class CreateManagerScreen extends StatefulWidget {
  const CreateManagerScreen({Key? key}) : super(key: key);

  @override
  _CreateManagerScreenState createState() => _CreateManagerScreenState();
}

class _CreateManagerScreenState extends State<CreateManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

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

  Future<void> _createManager() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final db = await DatabaseService.instance.database;

      // Kiểm tra email và username đã tồn tại chưa
      final existingUsers = await db.query(
        DatabaseConfig.tableUsers,
        where: 'email = ? OR username = ?',
        whereArgs: [_emailController.text, _usernameController.text],
      );

      if (existingUsers.isNotEmpty) {
        setState(() {
          _errorMessage = 'Email hoặc tên đăng nhập đã tồn tại';
          _isLoading = false;
        });
        return;
      }

      // Thêm quản lý mới vào database
      final now = DateTime.now().toIso8601String();
      final id = await db.insert(
        DatabaseConfig.tableUsers,
        {
          'email': _emailController.text,
          'username': _usernameController.text,
          'password':
              _passwordController.text, // Trong thực tế cần hash password
          'full_name': _fullNameController.text,
          'role': UserRole.manager.name,
          'phone': _phoneController.text,
          'is_active': 1,
          DatabaseConfig.columnCreatedAt: now,
          DatabaseConfig.columnUpdatedAt: now,
        },
      );

      if (id > 0) {
        setState(() {
          _successMessage = 'Đã tạo tài khoản quản lý thành công';
          _isLoading = false;
        });

        // Reset form
        _formKey.currentState!.reset();
        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _fullNameController.clear();
        _phoneController.clear();
      } else {
        setState(() {
          _errorMessage = 'Không thể tạo tài khoản quản lý';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Tạo tài khoản quản lý',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Cấp tài khoản cho quản lý mới',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),

              // Success message
              if (_successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),

              // Form fields
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
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
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
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
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
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
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !RegExp(r'^[0-9+\-\s]+$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createManager,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'TẠO TÀI KHOẢN',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
