import 'package:flutter/material.dart';
import 'package:mission_master/config/database_config.dart';
import 'package:mission_master/core/models/project.dart' hide ProjectStatus;
import 'package:mission_master/core/models/project.dart' as project_model
    show ProjectStatus;
import 'package:mission_master/core/models/role.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/services/database_service.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/features/manager/screens/create_project_screen.dart';
import 'package:mission_master/shared/widgets/app_bar_widget.dart';
import 'package:mission_master/shared/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mission_master/services/api_service.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  BottomNavItem _currentNavItem = BottomNavItem.projects;
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _users = []; // Để hiển thị tên quản lý và leader
  bool _isLoading = true;
  User? _currentUser; // Người dùng hiện tại (để kiểm tra quyền)

  // Calendar and filter variables
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Cần làm', 'Đang làm', 'Xong'];

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
      // Lấy dữ liệu từ API
      final apiService = ApiService.instance;
      
      // Lấy danh sách người dùng
      final users = await apiService.getUsers();
      
      // Lưu danh sách người dùng
      setState(() {
        _users = users;
      });
      
      // Lấy danh sách dự án
      final projects = await apiService.getProjects();
      
      // Lưu danh sách dự án
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}'))
      );
    }
  }

  // Lọc dự án dựa trên ngày được chọn và bộ lọc
  List<Project> _getFilteredProjects() {
    return _projects.map((projectMap) {
      // Chuyển đổi Map<String, dynamic> thành Project
      return Project.fromMap(projectMap);
    }).where((project) {
      // Lọc theo ngày
      final projectStartDate = DateTime.parse(project.startDate);
      final isSameDay = projectStartDate.year == _selectedDate.year &&
          projectStartDate.month == _selectedDate.month &&
          projectStartDate.day == _selectedDate.day;

      // Nếu đã chọn một ngày cụ thể, chỉ hiển thị dự án bắt đầu vào ngày đó
      if (!isSameDay) {
        return false;
      }

      // Lọc theo trạng thái
      if (_selectedFilter == 'Tất cả') {
        return true;
      } else if (_selectedFilter == 'Cần làm') {
        return project.status == project_model.ProjectStatus.notStarted.value;
      } else if (_selectedFilter == 'Đang làm') {
        return project.status == project_model.ProjectStatus.inProgress.value;
      } else if (_selectedFilter == 'Xong') {
        return project.status == project_model.ProjectStatus.completed.value;
      }
      
      return true;
    }).toList();
  }

  void _handleNavItemSelected(BottomNavItem item) {
    setState(() {
      _currentNavItem = item;
    });

    if (item != BottomNavItem.projects) {
      String route = '/';
      switch (item) {
        case BottomNavItem.home:
          route = '/home';
          break;
        case BottomNavItem.tasks:
          route = '/tasks';
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
    
    // Tìm người dùng trong danh sách Map<String, dynamic>
    final userMap = _users.firstWhere(
      (user) => user['id'] == userId,
      orElse: () => {
        'full_name': 'Không tìm thấy'
      },
    );
    
    // Trả về tên người dùng
    return userMap['full_name'] ?? 'N/A';
  }

  // Mở màn hình tạo dự án mới
  void _openCreateProjectScreen() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn cần đăng nhập để thực hiện chức năng này')),
      );
      return;
    }

    // Kiểm tra quyền (chỉ admin và manager mới có thể tạo dự án)
    if (!_currentUser!.isAdmin && !_currentUser!.isManager) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn không có quyền tạo dự án')),
      );
      return;
    }

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(currentUser: _currentUser!),
      ),
    )
        .then((_) {
      // Reload data when returning from create project screen
      _loadData();
    });
  }

  // Lấy màu trạng thái dự án tương ứng với status
  Color _getStatusColor(String status) {
    switch (project_model.ProjectStatus.fromString(status)) {
      case project_model.ProjectStatus.notStarted:
        return AppColors.primaryMedium;
      case project_model.ProjectStatus.inProgress:
        return AppColors.accent;
      case project_model.ProjectStatus.completed:
        return Colors.green;
      case project_model.ProjectStatus.cancelled:
        return Colors.grey;
    }
    return Colors.grey;
  }

  // Lấy màu nền cho trạng thái dự án
  Color _getStatusBackgroundColor(String status) {
    switch (project_model.ProjectStatus.fromString(status)) {
      case project_model.ProjectStatus.notStarted:
        return Color(0xFFE1F5FF);
      case project_model.ProjectStatus.inProgress:
        return Color(0xFFFFF0E1);
      case project_model.ProjectStatus.completed:
        return Color(0xFFE1FFE5);
      case project_model.ProjectStatus.cancelled:
        return Color(0xFFEEEEEE);
    }
    return Color(0xFFEEEEEE);
  }

  // Chuyển đổi từ status sang tên hiển thị
  String _getStatusDisplayName(String status) {
    switch (project_model.ProjectStatus.fromString(status)) {
      case project_model.ProjectStatus.notStarted:
        return 'Cần làm';
      case project_model.ProjectStatus.inProgress:
        return 'Đang làm';
      case project_model.ProjectStatus.completed:
        return 'Xong';
      case project_model.ProjectStatus.cancelled:
        return 'Đã hủy';
    }
    return 'Không xác định';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F8),
      appBar: AppBarWidget(
        title: 'Dự Án',
        showBackButton: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                _buildFilterTabs(),
                Expanded(
                  child: _buildProjectList(),
                ),
                _buildAddProjectButton(),
              ],
            ),
      bottomNavigationBar: BottomNavBarWidget(
        currentItem: _currentNavItem,
        onItemSelected: _handleNavItemSelected,
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.week,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: AppColors.primaryMedium,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primaryMedium.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primaryMedium,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          Color bgColor = Colors.white;
          Color textColor = Colors.black87;
          if (filter == 'Tất cả') {
            bgColor =
                isSelected ? Color(0xFF005E6A) : AppColors.filterBackground;
            textColor = isSelected ? Colors.white : Color(0xFF005E6A);
          } else if (filter == 'Cần làm') {
            bgColor = isSelected
                ? AppColors.primaryMedium
                : AppColors.filterBackground;
            textColor = isSelected ? Colors.white : AppColors.primaryMedium;
          } else if (filter == 'Đang làm') {
            bgColor =
                isSelected ? AppColors.accent : AppColors.filterBackground;
            textColor = isSelected ? Colors.white : AppColors.accent;
          } else {
            // 'Xong'
            bgColor = isSelected ? Colors.green : AppColors.filterBackground;
            textColor = isSelected ? Colors.white : Colors.green;
          }
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                filter,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectList() {
    final filteredProjects = _getFilteredProjects();

    if (filteredProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không có dự án nào',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vào ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final project = filteredProjects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    final statusText = _getStatusDisplayName(project.status);
    final statusColor = _getStatusColor(project.status);
    final statusBgColor = _getStatusBackgroundColor(project.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Yêu cầu kĩ thuật",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            project.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryMedium,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getUserName(project.leaderId),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('hh:mm a').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Các helper methods
  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getDaysRemainingColor(int days) {
    if (days < 0) return Colors.red;
    if (days < 3) return Colors.orange;
    if (days < 7) return Colors.amber;
    return Colors.green;
  }

  // Nút thêm dự án mới ở dưới cùng
  Widget _buildAddProjectButton() {
    // Nếu không phải admin/manager thì không hiển thị nút
    if (_currentUser == null ||
        (!_currentUser!.isAdmin && !_currentUser!.isManager)) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _openCreateProjectScreen,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          'Thêm dự án mới',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
