import 'package:flutter/material.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/features/admin/screens/employee_detail_screen.dart';
import 'package:mission_master/features/admin/widgets/admin_app_bar.dart';
import 'package:mission_master/features/admin/widgets/admin_bottom_nav_bar.dart';
import 'package:mission_master/features/admin/widgets/admin_drawer.dart';
import 'package:mission_master/services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  AdminNavItem _currentNavItem = AdminNavItem.dashboard;
  String _searchQuery = '';
  String _activeFilter = 'Tất cả';
  List<User> _users = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final TextEditingController _searchController = TextEditingController();

  // Lưu trữ số lượng task của mỗi người dùng
  final Map<int, int> _userTaskCounts = {};

  // Tham số phân trang
  int _currentPage = 1;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  String _currentStatusFilter = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchUsers();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreUsers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      // In ra giá trị _currentStatusFilter để debug
      print('Fetching users with status filter: $_currentStatusFilter');

      // Sử dụng phương thức mới với bộ lọc và phân trang
      final users = await ApiService.instance.getUsersWithFilter(
        status: _currentStatusFilter,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        limit: _pageSize,
      );

      setState(() {
        // Chuyển đổi danh sách map thành đối tượng User
        _users = users.map((json) => User.fromMap(json)).toList();
        _isLoading = false;
        _hasMoreData = users.length >= _pageSize;
      });

      // Lấy số lượng task của mỗi người dùng
      _fetchTaskCounts();

      print('Loaded ${_users.length} users successfully');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('Error loading users: $e');
    }
  }

  // Lấy số lượng task của mỗi người dùng
  Future<void> _fetchTaskCounts() async {
    for (final user in _users) {
      if (user.id != null) {
        try {
          final count =
              await ApiService.instance.getTaskCountByUserId(user.id!);
          setState(() {
            _userTaskCounts[user.id!] = count;
          });
        } catch (e) {
          print('Error fetching task count for user ${user.id}: $e');
        }
      }
    }
  }

  Future<void> _loadMoreUsers() async {
    if (!_hasMoreData || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final users = await ApiService.instance.getUsersWithFilter(
        status: _currentStatusFilter,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: nextPage,
        limit: _pageSize,
      );

      final newUsers = users.map((json) => User.fromMap(json)).toList();

      setState(() {
        _users.addAll(newUsers);
        _currentPage = nextPage;
        _isLoadingMore = false;
        _hasMoreData = newUsers.length >= _pageSize;
      });

      // Lấy số lượng task của người dùng mới
      for (final user in newUsers) {
        if (user.id != null) {
          try {
            final count =
                await ApiService.instance.getTaskCountByUserId(user.id!);
            setState(() {
              _userTaskCounts[user.id!] = count;
            });
          } catch (e) {
            print('Error fetching task count for user ${user.id}: $e');
          }
        }
      }

      print('Loaded ${newUsers.length} more users, total: ${_users.length}');
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print('Error loading more users: $e');
    }
  }

  List<User> get _filteredUsers {
    List<User> filtered = _users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((user) =>
              user.fullName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              user.id.toString().contains(_searchQuery) ||
              user.username
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    if (_activeFilter == 'Đang hoạt động') {
      filtered = filtered.where((user) => user.isActive).toList();
    } else if (_activeFilter == 'Đã khóa') {
      filtered = filtered.where((user) => !user.isActive).toList();
    }

    return filtered;
  }

  void _handleLogout() {
    // Xử lý đăng xuất
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: AdminDrawer(onLogout: _handleLogout),
      appBar: const AdminAppBar(
        title: 'Administrator',
      ),
      bottomNavigationBar: AdminBottomNavBar(
        currentItem: AdminNavItem.dashboard,
        onItemSelected: (item) {
          if (item != AdminNavItem.dashboard) {
            switch (item) {
              case AdminNavItem.users:
                // Chuyển đến trang Profile khi nhấn vào tab Users
                Navigator.pushNamed(context, '/admin/profile');
                break;
              case AdminNavItem.dashboard:
                // Đã ở trang dashboard, không cần điều hướng
                break;
            }
          }
        },
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhân viên...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('Tất cả'),
                const SizedBox(width: 8),
                _buildFilterChip('Đang hoạt động'),
                const SizedBox(width: 8),
                _buildFilterChip('Đã khóa'),
              ],
            ),
          ),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            _filteredUsers.length + (_hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredUsers.length) {
                            return _isLoadingMore
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: _showAddUserDialog,
        shape: const CircleBorder(),
        elevation: 4.0,
        fillColor: Colors.transparent,
        constraints: const BoxConstraints.tightFor(width: 56.0, height: 56.0),
        child: Image.asset(
          'assets/images/add_admin.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;

          // Cập nhật _currentStatusFilter dựa trên filter được chọn
          switch (label) {
            case 'Tất cả':
              _currentStatusFilter = '';
              break;
            case 'Đang hoạt động':
              _currentStatusFilter = 'active';
              break;
            case 'Đã khóa':
              _currentStatusFilter = 'inactive';
              break;
          }

          // In ra giá trị _currentStatusFilter để debug
          print(
              'Selected filter: $label, Status filter: $_currentStatusFilter');
        });
        _fetchUsers();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMedium : const Color(0xFFE6F7F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Hiển thị dialog thêm người dùng mới
  void _showAddUserDialog() {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'employee';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm người dùng mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Họ tên'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                items: const [
                  DropdownMenuItem(value: 'employee', child: Text('Nhân viên')),
                  DropdownMenuItem(value: 'manager', child: Text('Quản lý')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Gọi API để tạo người dùng mới
                await ApiService.instance.register({
                  'full_name': fullNameController.text,
                  'email': emailController.text,
                  'username': usernameController.text,
                  'password': passwordController.text,
                  'role': selectedRole,
                });

                Navigator.pop(context);

                // Cập nhật lại danh sách người dùng
                _fetchUsers();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Đã tạo người dùng mới thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
            ),
            child: const Text('Tạo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog chỉnh sửa thông tin người dùng
  void _showEditUserDialog(User user) {
    // Điều hướng đến màn hình chi tiết nhân viên
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(userId: user.id!),
      ),
    ).then((_) {
      // Khi quay lại từ màn hình chi tiết, cập nhật lại danh sách người dùng
      _fetchUsers();
    });
  }

  // Xử lý khi người dùng nhấn nút khóa/mở khóa
  Future<void> _toggleUserStatus(User user) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedUserData = await ApiService.instance.updateUserStatus(
        user.id ?? 0,
        !user.isActive,
      );

      setState(() {
        _isLoading = false;
      });

      // Cập nhật lại danh sách người dùng
      _fetchUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Đã ${user.isActive ? 'khóa' : 'mở khóa'} người dùng ${user.fullName}')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  Widget _buildUserCard(User user) {
    // Sử dụng màu nền khác nhau cho tài khoản bị khóa và không bị khóa
    final backgroundColor = user.isActive
        ? const Color(0xFFECF5F7) // Màu cho tài khoản không bị khóa
        : const Color(0xFFF4D6D9); // Màu cho tài khoản bị khóa

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withOpacity(1.0),
            backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          // Shadow chính
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          // Shadow mờ nhẹ bên trên tạo hiệu ứng 3D
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        // Thêm viền mỏng để tạo hiệu ứng 3D
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          user.fullName,
          style: const TextStyle(
              fontWeight: FontWeight.w900, color: AppColors.primaryDark),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.task,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_userTaskCounts[user.id] ?? 0} nhiệm vụ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showEditUserDialog(user),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/user-setting.png',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _toggleUserStatus(user),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.amber.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  user.isActive
                      ? 'assets/images/lock.png'
                      : 'assets/images/unlock.png',
                  width: 28,
                  height: 28,
                  color: user.isActive ? Colors.amber : Colors.green,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showEditUserDialog(user),
      ),
    );
  }
}
