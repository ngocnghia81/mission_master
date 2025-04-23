import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/shared/widgets/app_bar_widget.dart';
import 'package:mission_master/shared/widgets/bottom_nav_bar.dart';

class CalendarTaskScreen extends StatefulWidget {
  @override
  _CalendarTaskScreenState createState() => _CalendarTaskScreenState();
}

class _CalendarTaskScreenState extends State<CalendarTaskScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  int _selectedDayIndex = 2; // Ngày 28 (Thứ 5) theo hình
  String _selectedFilter = 'Cần làm';
  String? _expandedTaskId; // Lưu ID của task đang được mở rộng
  BottomNavItem _currentNavItem = BottomNavItem.home;

  final List<String> _filters = ['Tất cả', 'Cần làm', 'Đang làm', 'Xong'];

  // Dùng để lưu trữ nhiệm vụ từ backend sau này
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Phương thức này sẽ được sử dụng để load dữ liệu từ backend
  Future<void> _loadTasks() async {
    // Mock data - sẽ được thay thế bằng API call sau này
    setState(() {
      _tasks = [
        Task(
          id: '1',
          title: 'Tản canh giờ lạnh',
          projectName: 'Thiết kế Figma - Quản lý',
          startDate: DateTime(2025, 3, 20),
          endDate: DateTime(2025, 3, 29),
          status: 'Đang làm',
          subtasks: [
            Subtask(id: '1', title: 'Đăng nhập', isCompleted: true),
            Subtask(id: '2', title: 'Trang chủ', isCompleted: true),
            Subtask(id: '3', title: 'Dự án', isCompleted: true),
            Subtask(id: '4', title: 'Thêm dự án', isCompleted: false),
            Subtask(id: '5', title: 'Dự án', isCompleted: true),
            Subtask(id: '6', title: 'gì đó', isCompleted: false),
          ],
        ),
        Task(
          id: '2',
          title: 'Thiết kế database',
          projectName: 'Hồ Huỳnh Anh Ngân - 20012292912',
          startDate: DateTime.now(),
          endDate: DateTime(2025, 4, 9),
          status: 'Cần làm',
          completionPercentage: 80,
        ),
      ];
    });
  }

  void _handleNavItemSelected(BottomNavItem item) {
    setState(() {
      _currentNavItem = item;
    });
    // Ở đây sẽ xử lý điều hướng đến các màn hình khác
    // Ví dụ:
    // if (item == BottomNavItem.tasks) {
    //   Navigator.of(context).pushNamed('/tasks');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F8),
      appBar: AppBarWidget(
        title: 'Việc cần làm',
        showBackButton: false,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          _buildFilterTabs(),
          Expanded(
            child: _buildTaskList(),
          ),
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

  // Widget tạo card thu gọn cho cả "Thiết kế database" và "Tản canh giờ lạnh"
  Widget _buildCollapsedCard(Task task) {
    bool isDesignTask = task.title == 'Thiết kế database';

    return GestureDetector(
      onTap: () {
        setState(() {
          // Nếu đã mở rộng thì thu gọn, nếu chưa thì mở rộng
          _expandedTaskId = _expandedTaskId == task.id ? null : task.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.projectName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8CA892),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isDesignTask
                        ? DateFormat('dd/MM/yyyy').format(task.endDate)
                        : '${DateFormat('dd/MM/yyyy').format(task.startDate)} - ${DateFormat('dd/MM/yyyy').format(task.endDate)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.highlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Right side - Progress/Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: task.status == 'Đang làm'
                        ? const Color(0xFFFFF0E1)
                        : task.status == 'Cần làm'
                            ? Color(0xFFE1F5FF)
                            : Color(0xFFE1FFE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      color: task.status == 'Đang làm'
                          ? AppColors.accent
                          : task.status == 'Cần làm'
                              ? AppColors.primaryMedium
                              : Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: task.completionPercentage != null
                              ? task.completionPercentage! / 100
                              : 0.0,
                          backgroundColor: const Color(0xFFEEEEEE),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryMedium),
                          strokeWidth: 5,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${task.completionPercentage ?? 0}%',
                          style: TextStyle(
                            color: AppColors.primaryMedium,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }

  // Widget hiển thị card mở rộng với danh sách công việc
  Widget _buildExpandedCard(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
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
          // Header with title and status/progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMedium,
                ),
              ),
              task.title == 'Thiết kế database'
                  ? Container(
                      width: 32,
                      height: 32,
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryMedium,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${task.completionPercentage ?? 0}%',
                          style: TextStyle(
                            color: AppColors.primaryMedium,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Đang làm',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 8),
          // Project name
          Text(
            task.projectName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          // Date range
          Text(
            task.title == 'Thiết kế database'
                ? DateFormat('dd/MM/yyyy').format(task.endDate)
                : '${DateFormat('dd/MM/yyyy').format(task.startDate)} - ${DateFormat('dd/MM/yyyy').format(task.endDate)}',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.highlight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Subtasks list
          if (task.subtasks != null && task.subtasks!.isNotEmpty)
            ...task.subtasks!.map((subtask) =>
                _buildSubtaskItem(subtask.isCompleted, subtask.title)),
          // Add a "collapse" button at the bottom
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _expandedTaskId = null;
                });
              },
              icon: const Icon(Icons.keyboard_arrow_up),
              label: const Text('Thu gọn'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    // Lọc nhiệm vụ theo trạng thái được chọn
    final filteredTasks = _tasks.where((task) {
      if (_selectedFilter == 'Tất cả') return true;
      return task.status == _selectedFilter;
    }).toList();

    // Hiển thị các task dựa theo filter đã chọn
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        // Nếu task đang được mở rộng, hiển thị dạng mở rộng
        if (_expandedTaskId == task.id) {
          return _buildExpandedCard(task);
        }
        // Ngược lại hiển thị dạng thu gọn
        return _buildCollapsedCard(task);
      },
    );
  }

  // Helper Widget for subtask items with checkbox
  Widget _buildSubtaskItem(bool isCompleted, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.transparent,
              border: Border.all(
                color: isCompleted ? Colors.transparent : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Model classes để chuẩn bị cho việc tích hợp backend
class Task {
  final String id;
  final String title;
  final String projectName;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'Cần làm', 'Đang làm', 'Xong'
  final List<Subtask>? subtasks;
  final int? completionPercentage;

  Task({
    required this.id,
    required this.title,
    required this.projectName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.subtasks,
    this.completionPercentage,
  });

  // Phương thức factory để tạo Task từ JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    List<Subtask>? subtasks;
    if (json['subtasks'] != null) {
      subtasks = (json['subtasks'] as List)
          .map((subtaskJson) => Subtask.fromJson(subtaskJson))
          .toList();
    }

    return Task(
      id: json['id'],
      title: json['title'],
      projectName: json['project_name'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      subtasks: subtasks,
      completionPercentage: json['completion_percentage'],
    );
  }

  // Phương thức để chuyển đối tượng Task thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'project_name': projectName,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'subtasks': subtasks?.map((subtask) => subtask.toJson()).toList(),
      'completion_percentage': completionPercentage,
    };
  }
}

class Subtask {
  final String id;
  final String title;
  final bool isCompleted;

  Subtask({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  // Phương thức factory để tạo Subtask từ JSON
  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['is_completed'],
    );
  }

  // Phương thức để chuyển đối tượng Subtask thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
    };
  }
}
