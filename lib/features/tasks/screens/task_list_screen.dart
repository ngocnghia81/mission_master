import 'package:flutter/material.dart';
import 'package:mission_master/core/models/task.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/shared/widgets/app_bar_widget.dart';
import 'package:mission_master/shared/widgets/bottom_nav_bar.dart';
import 'package:mission_master/services/api_service.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  BottomNavItem _currentNavItem = BottomNavItem.tasks;
  List<Task> _tasks = [];
  List<User> _users = []; // Để hiển thị tên người được giao
  bool _isLoading = true;
  User? _currentUser; // Người dùng hiện tại

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiService.instance;

      // Load users từ API
      final usersData = await api.getUsers();
      _users = usersData.map((map) => User.fromMap(map)).toList();
      
      // Lấy người dùng đầu tiên làm demo
      if (_users.isNotEmpty) {
        _currentUser = _users.first;
      }

      // Load tasks từ API
      final tasksData = await api.getTasks();
      _tasks = tasksData.map((map) => Task.fromMap(map)).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleNavItemSelected(BottomNavItem item) {
    setState(() {
      _currentNavItem = item;
    });

    if (item != BottomNavItem.tasks) {
      String route = '/';
      switch (item) {
        case BottomNavItem.home:
          route = '/home';
          break;
        case BottomNavItem.projects:
          route = '/projects';
          break;
        default:
          route = '/';
      }

      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  // Tìm tên người dùng dựa vào ID
  String _getUserName(int? userId) {
    if (userId == null) return 'N/A';
    final user = _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(
        email: '',
        username: '',
        fullName: 'Không tìm thấy',
        role: '',
        isActive: false,
        createdAt: '',
        updatedAt: '',
      ),
    );
    return user.fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F8),
      appBar: AppBarWidget(
        title: 'Danh sách nhiệm vụ',
        showBackButton: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có nhiệm vụ nào',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Biểu tượng ưu tiên
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(task.priority),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getPriorityIcon(task.priority),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Trạng thái: ${_getStatusDisplayName(task.status)}',
                                        style: TextStyle(
                                          color: _getStatusColor(task.status),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (task.description != null &&
                                task.description!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text(
                                  task.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Deadline',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        // Tính ngày đến hạn từ dueDays và ngày bắt đầu
                                        task.createdAt.add(Duration(days: task.dueDays)).toString() != null
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(task.createdAt.add(Duration(days: task.dueDays)))
                                            : 'Không có',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: task.createdAt.add(Duration(days: task.dueDays)).isBefore(DateTime.now())
                                              ? Colors.red
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Người được giao',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        task.assignedTo != null
                                            ? _getUserName(task.assignedTo)
                                            : 'Chưa phân công',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dự án',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'ID: ${task.membershipId}', // Sử dụng membershipId thay vì projectId
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavBarWidget(
        currentItem: _currentNavItem,
        onItemSelected: _handleNavItemSelected,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryMedium,
        child: const Icon(Icons.add),
        onPressed: () {
          // Sẽ triển khai sau với màn hình thêm nhiệm vụ
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Chức năng thêm nhiệm vụ sẽ được triển khai sau')));
        },
      ),
    );
  }

  // Helper methods
  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool _isPastDue(DateTime startDate, int dueDays) {
    final dueDate = startDate.add(Duration(days: dueDays));
    final now = DateTime.now();
    return dueDate.isBefore(now);
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'in_progress':
        return 'Đang thực hiện';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.arrow_downward;
      case 'medium':
        return Icons.remove;
      case 'high':
        return Icons.arrow_upward;
      default:
        return Icons.help_outline;
    }
  }
}
