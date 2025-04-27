import 'package:flutter/material.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/features/admin/widgets/admin_app_bar.dart';
import 'package:mission_master/features/admin/widgets/admin_bottom_nav_bar.dart';
import 'package:mission_master/services/api_service.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int userId;

  const EmployeeDetailScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  User? _user;
  bool _isLoading = true;
  int _taskCount = 0;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoadingTasks = false;
  bool _hasMoreTasks = true;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 10;

  // Biến lưu trữ thống kê nhiệm vụ
  int _completedTaskCount = 0;
  int _overdueTaskCount = 0;
  int _inProgressTaskCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingTasks &&
        _hasMoreTasks) {
      _loadMoreTasks();
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy thông tin người dùng theo ID
      final userData = await ApiService.instance.getUserById(widget.userId);
      final user = User.fromMap(userData);

      setState(() {
        _user = user;
        _isLoading = false;
      });

      // Lấy số lượng task của người dùng
      try {
        final count =
            await ApiService.instance.getTaskCountByUserId(widget.userId);
        setState(() {
          _taskCount = count;
        });

        // Lấy thống kê nhiệm vụ
        _fetchTaskStatistics();
      } catch (e) {
        print('Error fetching task count: $e');
      }

      // Lấy danh sách task của người dùng
      _fetchUserTasks();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchUserTasks() async {
    if (_isLoadingTasks) return;

    setState(() {
      _isLoadingTasks = true;
      _currentPage = 1;
    });

    try {
      final tasks = await ApiService.instance
          .getUserTasks(
        widget.userId,
        page: _currentPage,
        limit: _pageSize,
      )
          .catchError((e) {
        print('Error fetching user tasks: $e');
        return <Map<String, dynamic>>[];
      });

      setState(() {
        _tasks = tasks;
        _isLoadingTasks = false;
        _hasMoreTasks = tasks.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoadingTasks = false;
        _tasks = [];
        _hasMoreTasks = false;
      });
      print('Error fetching user tasks: $e');
    }
  }

  Future<void> _loadMoreTasks() async {
    if (_isLoadingTasks || !_hasMoreTasks) return;

    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final moreTasks = await ApiService.instance
          .getUserTasks(
        widget.userId,
        page: nextPage,
        limit: _pageSize,
      )
          .catchError((e) {
        print('Error loading more tasks: $e');
        return <Map<String, dynamic>>[];
      });

      setState(() {
        _tasks.addAll(moreTasks);
        _currentPage = nextPage;
        _isLoadingTasks = false;
        _hasMoreTasks = moreTasks.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoadingTasks = false;
        _hasMoreTasks = false; // Ngừng tải thêm nếu có lỗi
      });
      print('Error loading more tasks: $e');
    }
  }

  Future<void> _toggleUserStatus() async {
    if (_user == null) return;

    try {
      final result = await ApiService.instance.updateUserStatus(
        widget.userId,
        !_user!.isActive,
      );

      setState(() {
        _user = User.fromMap(result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _user!.isActive ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản',
          ),
          backgroundColor: _user!.isActive ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchTaskStatistics() async {
    try {
      // Lấy thống kê nhiệm vụ hoàn thành
      final completedStats = await ApiService.instance
          .getUserTaskStatistics(
        widget.userId,
        status: 'completed',
      )
          .catchError((e) {
        print('Error fetching completed task statistics: $e');
        return {'count': 0};
      });

      // Lấy thống kê nhiệm vụ quá hạn
      final overdueStats = await ApiService.instance
          .getUserTaskStatistics(
        widget.userId,
        status: 'overdue',
      )
          .catchError((e) {
        print('Error fetching overdue task statistics: $e');
        return {'count': 0};
      });

      // Lấy thống kê nhiệm vụ đang làm
      final inProgressStats = await ApiService.instance
          .getUserTaskStatistics(
        widget.userId,
        status: 'in_progress',
      )
          .catchError((e) {
        print('Error fetching in-progress task statistics: $e');
        return {'count': 0};
      });

      setState(() {
        _completedTaskCount = completedStats['count'] ?? 0;
        _overdueTaskCount = overdueStats['count'] ?? 0;
        _inProgressTaskCount = inProgressStats['count'] ?? 0;
      });
    } catch (e) {
      print('Error fetching task statistics: $e');

      // Nếu có lỗi, hiển thị giá trị mặc định
      setState(() {
        _completedTaskCount = 0;
        _overdueTaskCount = 0;
        _inProgressTaskCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Chi tiết nhân viên'),
      bottomNavigationBar: AdminBottomNavBar(
        currentItem: AdminNavItem.users, // Users tab
        onItemSelected: (item) {
          switch (item) {
            case AdminNavItem.dashboard:
              Navigator.pushNamed(context, '/admin/dashboard');
              break;
            case AdminNavItem.users:
              // Đã ở trang users, không cần điều hướng
              break;
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: _user != null
          ? FloatingActionButton(
              onPressed: _toggleUserStatus,
              backgroundColor: _user!.isActive ? Colors.red : Colors.green,
              child: Icon(_user!.isActive ? Icons.lock : Icons.lock_open),
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_user == null) {
      return const Center(child: Text('Không thể tải thông tin người dùng'));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeCard(),
            _buildStatisticsSection(),
            _buildTasksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _user!.isActive ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    _user!.isActive ? AppColors.primaryDark : Colors.grey,
                child: Text(
                  _getInitials(_user!.fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user!.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user!.role,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _user!.isActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _user!.isActive ? 'Đang hoạt động' : 'Đã khóa',
                            style: TextStyle(
                              color:
                                  _user!.isActive ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, _user!.email),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, _user!.phone ?? 'Chưa cập nhật'),
          // Hiển thị thông tin vai trò
          const SizedBox(height: 8),
          _buildInfoRow(Icons.work, _user!.roleDisplayName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    final textColor =
        _user!.isActive ? AppColors.primaryDark : Colors.redAccent;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? textColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê nhiệm vụ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Hoàn thành',
                  _completedTaskCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Đang làm',
                  _inProgressTaskCount.toString(),
                  Icons.access_time,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Quá hạn',
                  _overdueTaskCount.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách nhiệm vụ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tổng: $_taskCount',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _tasks.isEmpty && !_isLoadingTasks
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có nhiệm vụ nào',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    ..._tasks.map((task) => _buildTaskItem(task)),
                    if (_isLoadingTasks)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_hasMoreTasks && !_isLoadingTasks)
                      Center(
                        child: TextButton.icon(
                          onPressed: _loadMoreTasks,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tải thêm'),
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final String title = task['title'] ?? 'Không có tiêu đề';
    final String status = task['status'] ?? 'not_assigned';
    final String priority = task['priority'] ?? 'medium';
    final String deadline = task['deadline'] != null
        ? task['deadline'].toString().substring(0, 10)
        : 'Không có hạn';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Hạn: $deadline',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(priority),
                    style: TextStyle(
                      color: _getPriorityColor(priority),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {
          // Xem chi tiết task
        },
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'not_assigned':
        return 'Chưa giao';
      case 'in_progress':
        return 'Đang làm';
      case 'completed':
        return 'Hoàn thành';
      case 'overdue':
        return 'Quá hạn';
      default:
        return 'Không xác định';
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return 'Cao';
      case 'medium':
        return 'Trung bình';
      case 'low':
        return 'Thấp';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> nameParts = fullName.split(' ');
    if (nameParts.length == 1) return nameParts[0][0];

    return nameParts.first[0] + nameParts.last[0];
  }
}
