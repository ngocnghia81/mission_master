import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/features/admin/widgets/admin_app_bar.dart';
import 'package:mission_master/features/admin/widgets/admin_drawer.dart';
import 'package:mission_master/services/api_service.dart';
import 'package:mission_master/services/email_service.dart';

class CreateManagerScreen extends StatefulWidget {
  const CreateManagerScreen({Key? key}) : super(key: key);

  @override
  State<CreateManagerScreen> createState() => _CreateManagerScreenState();
}

class _CreateManagerScreenState extends State<CreateManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;
  String _generatedPassword = '';
  String _generatedUsername = '';

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createManagerAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSuccess = false;
    });

    try {
      // Tạo mật khẩu ngẫu nhiên
      final password = EmailService.instance.generateRandomPassword();
      _generatedPassword = password;
      
      // Tạo username từ email
      _generatedUsername = EmailService.instance.generateUsernameFromEmail(_emailController.text.trim());

      // Tạo tài khoản quản lý
      final success = await ApiService.instance.createManagerAccount(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        username: _generatedUsername,
        password: password,
      );

      if (success) {
        // Gửi email với thông tin đăng nhập
        final emailSent = await EmailService.instance.sendWelcomeEmail(
          email: _emailController.text.trim(),
          fullName: _fullNameController.text.trim(),
          username: _generatedUsername,
          password: password,
        );

        if (emailSent) {
          setState(() {
            _isSuccess = true;
            _isLoading = false;
          });
          
          // Hiển thị thông báo thành công
          _showSuccessDialog();
        } else {
          setState(() {
            _errorMessage = 'Tạo tài khoản thành công nhưng không gửi được email. Vui lòng thử lại.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Không thể tạo tài khoản quản lý. Vui lòng thử lại.';
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tạo tài khoản thành công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tài khoản quản lý đã được tạo thành công và email thông báo đã được gửi.'),
            const SizedBox(height: 16),
            const Text('Thông tin đăng nhập:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tên đăng nhập: $_generatedUsername'),
            Text('Mật khẩu: $_generatedPassword'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
            ),
            child: const Text('Tạo tài khoản khác'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _fullNameController.clear();
    _emailController.clear();
    setState(() {
      _isSuccess = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: AdminDrawer(onLogout: _handleLogout),
      appBar: const AdminAppBar(
        title: 'Tạo tài khoản quản lý',
        showDrawerButton: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Tạo tài khoản quản lý mới',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Điền thông tin để tạo tài khoản quản lý. Mật khẩu sẽ được tạo tự động và gửi qua email.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'Họ và tên',
              hintText: 'Nhập họ và tên đầy đủ',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'Nhập địa chỉ email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: const Text(
                      'Tên đăng nhập sẽ được tạo tự động từ địa chỉ email và mật khẩu sẽ được gửi qua email.',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createManagerAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Tạo tài khoản',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.primaryMedium),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryMedium),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
        ),
      ],
    );
  }
}
