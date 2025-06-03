import 'package:flutter/material.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/features/admin/widgets/admin_app_bar.dart';
import 'package:mission_master/features/admin/widgets/admin_bottom_nav_bar.dart';
import 'package:mission_master/features/admin/widgets/admin_drawer.dart';
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
      // Lấy thông tin người dùng theo ID từ API
      final userData = await ApiService.instance.getUserById(widget.userId);
      final user = User.fromMap(userData);

      setState(() {
        _user = user;
        _isLoading = false;
      });

      // Lấy số lượng task của người dùng
      _fetchTaskCount();

      // Lấy thống kê nhiệm vụ
      _fetchTaskStatistics();

      // Lấy danh sách task của người dùng
      _fetchUserTasks();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user data: $e');
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin người dùng: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _fetchTaskCount() async {
    try {
      // Lấy thống kê tổng hợp
      final statistics = await ApiService.instance.getUserTaskStatistics(widget.userId);
      setState(() {
        _taskCount = statistics['total_count'] ?? 0;
      });
    } catch (e) {
      print('Error fetching task count: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải số lượng nhiệm vụ: ${e.toString()}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _fetchTaskStatistics() async {
    try {
      // Lấy thống kê tổng hợp
      final statistics = await ApiService.instance.getUserTaskStatistics(widget.userId);
      
      setState(() {
        _completedTaskCount = statistics['completed_count'] ?? 0;
        _overdueTaskCount = statistics['overdue_count'] ?? 0;
        _inProgressTaskCount = statistics['in_progress_count'] ?? 0;
      });
    } catch (e) {
      print('Error fetching task statistics: $e');

      // Nếu có lỗi, hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể tải thống kê nhiệm vụ'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Hiển thị giá trị mặc định
      setState(() {
        _completedTaskCount = 0;
        _overdueTaskCount = 0;
        _inProgressTaskCount = 0;
      });
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
      );

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
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách nhiệm vụ: ${e.toString()}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
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
      );

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
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thêm nhiệm vụ: ${e.toString()}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
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

  void _handleLogout() {
    // Xử lý đăng xuất
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(onLogout: _handleLogout),
      appBar: AdminAppBar(
        title: 'Chi tiết nhân viên',
        showDrawerButton: false,
        showBackButton: true,
      ),
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
    if (_user == null) {
      return Container(
        width: double.infinity,
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
        child: const Center(
          child: Text('Không có thông tin người dùng'),
        ),
      );
    }
    
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
                      _user!.roleDisplayName,
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
          const SizedBox(height: 8),
          _buildInfoRow(Icons.work, _user!.roleDisplayName),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today, 
            'Tham gia: ${_formatDate(_user!.createdAt)}',
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.update, 
            'Cập nhật: ${_formatDate(_user!.updatedAt)}',
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    if (_user == null) return Container();
    
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
    if (_user == null) {
      return Container();
    }
    
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
                    if (_tasks.isNotEmpty)
                      ..._tasks.map((task) => _buildTaskItem(task))
                    else if (_isLoadingTasks)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_hasMoreTasks && !_isLoadingTasks && _tasks.isNotEmpty)
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
    // Lấy thông tin từ task object
    final String title = task['title'] ?? 'Không có tiêu đề';
    final String description = task['description'] ?? 'Không có mô tả';
    final String status = task['status'] ?? 'not_assigned';
    final String priority = task['priority'] ?? 'medium';
    
    // Xử lý ngày tháng
    String dueDate = 'Không có hạn';
    if (task['due_days'] != null) {
      try {
        final int dueDays = int.tryParse(task['due_days'].toString()) ?? 0;
        DateTime? startDate;
        
        if (task['start_date'] != null && task['start_date'].toString().isNotEmpty) {
          startDate = DateTime.parse(task['start_date'].toString());
        }
        
        if (startDate != null) {
          final DateTime dueDateObj = startDate.add(Duration(days: dueDays));
          dueDate = '${dueDateObj.day}/${dueDateObj.month}/${dueDateObj.year}';
        } else {
          dueDate = '$dueDays ngày';
        }
      } catch (e) {
        print('Error calculating due date: $e');
        dueDate = 'Không xác định';
      }
    }
    
    // Lấy thông tin dự án từ database
    final String projectName = task['project_name'] ?? 'Không thuộc dự án';

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
            if (description.isNotEmpty && description != 'Không có mô tả') ...[
              const SizedBox(height: 4),
              Text(
                description.length > 50 ? '${description.substring(0, 50)}...' : description,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    projectName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Hạn: $dueDate',
                  style: TextStyle(
                    color: status == 'overdue' ? Colors.red : Colors.grey[600], 
                    fontSize: 12,
                    fontWeight: status == 'overdue' ? FontWeight.bold : FontWeight.normal,
                  ),
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
          _showTaskDetailDialog(task);
        },
      ),
    );
  }
  
  void _showTaskDetailDialog(Map<String, dynamic> task) {
    // Tính ngày hoàn thành từ start_date và due_days
    String dueDate = 'Không có hạn';
    if (task['due_days'] != null) {
      try {
        final int dueDays = int.tryParse(task['due_days'].toString()) ?? 0;
        DateTime? startDate;
        
        if (task['start_date'] != null && task['start_date'].toString().isNotEmpty) {
          startDate = DateTime.parse(task['start_date'].toString());
        }
        
        if (startDate != null) {
          final DateTime dueDateObj = startDate.add(Duration(days: dueDays));
          dueDate = '${dueDateObj.day}/${dueDateObj.month}/${dueDateObj.year}';
        } else {
          dueDate = '$dueDays ngày từ ngày bắt đầu';
        }
      } catch (e) {
        print('Error calculating due date: $e');
        dueDate = 'Không xác định';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task['title'] ?? 'Chi tiết nhiệm vụ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mô tả: ${task['description'] ?? 'Không có mô tả'}'),
              const SizedBox(height: 8),
              Text('Dự án: ${task['project_name'] ?? 'Không thuộc dự án'}'),
              const SizedBox(height: 8),
              Text('Trạng thái: ${_getStatusText(task['status'] ?? 'not_assigned')}'),
              const SizedBox(height: 8),
              Text('Độ ưu tiên: ${_getPriorityText(task['priority'] ?? 'medium')}'),
              const SizedBox(height: 8),
              Text('Ngày bắt đầu: ${_formatTaskDate(task['start_date'])}'),
              const SizedBox(height: 8),
              Text('Thời hạn: $dueDate (${task['due_days'] ?? 0} ngày)'),
              const SizedBox(height: 8),
              Text('Ngày tạo: ${_formatTaskDate(task['created_at'])}'),
              const SizedBox(height: 8),
              Text('Cập nhật lần cuối: ${_formatTaskDate(task['updated_at'])}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  String _formatTaskDate(dynamic dateStr) {
    if (dateStr == null) return 'Không có dữ liệu';
    if (dateStr.toString().isEmpty) return 'Không có dữ liệu';
    
    try {
      final DateTime date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      print('Error parsing date: $e');
      return 'Không hợp lệ';
    }
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
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0] : '';
    }

    return (nameParts.first.isNotEmpty ? nameParts.first[0] : '') + 
           (nameParts.last.isNotEmpty ? nameParts.last[0] : '');
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Không có dữ liệu';
    
    try {
      DateTime dateTime;
      
      if (dateValue is String) {
        dateTime = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        dateTime = dateValue;
      } else {
        return 'Định dạng không hợp lệ';
      }
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Định dạng không hợp lệ';
    }
  }
}
