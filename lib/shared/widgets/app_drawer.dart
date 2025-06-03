import 'package:flutter/material.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/services/api_service.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback onLogout;

  const AppDrawer({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await ApiService.instance.getCurrentUser();
      setState(() {
        _currentUser = User.fromMap(userData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching current user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header với thông tin người dùng
            _buildHeader(),

            // Divider
            const Divider(height: 1, thickness: 1),

            // Menu items
            _buildMenuItem(
              icon: Icons.home,
              title: 'Trang chủ',
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),

            _buildMenuItem(
              icon: Icons.assignment,
              title: 'Nhiệm vụ',
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                Navigator.pushNamed(context, '/tasks');
              },
            ),

            _buildMenuItem(
              icon: Icons.work,
              title: 'Dự án',
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                Navigator.pushNamed(context, '/projects');
              },
            ),

            _buildMenuItem(
              icon: Icons.person,
              title: 'Hồ sơ cá nhân',
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                // TODO: Thêm route cho profile của user thường
              },
            ),

            const Spacer(),

            // Logout button
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                widget.onLogout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: AppColors.primaryDark,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        _getInitials(_currentUser?.fullName ?? 'User'),
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.fullName ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.roleDisplayName ?? 'Nhân viên',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryMedium),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> nameParts = fullName.split(' ');
    if (nameParts.length == 1) return nameParts[0][0];

    return nameParts.first[0] + nameParts.last[0];
  }
} 