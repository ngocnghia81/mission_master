import 'package:flutter/material.dart';
import 'TaskItemWidget.dart';

class TaskListWidget extends StatelessWidget {
  final DateTime selectedDate;

  TaskListWidget({required this.selectedDate});

  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Tàn canh gió lạnh',
      'status': 'Kết thúc',
      'subTasks': [
        {'name': 'Đăng nhập'},
        {'name': 'Trang chủ'},
        {'name': 'Dự án'},
        {'name': 'Thêm dự án'},
        {'name': 'Dự án con'},
      ],
      'dueDate': DateTime(2025, 4, 2),
    },
    {
      'title': 'Tàn canh gió lạnh',
      'status': 'Hủy',
      'subTasks': [
        {'name': 'Đăng nhập'},
        {'name': 'Trang chủ'},
        {'name': 'Dự án'},
        {'name': 'Thêm dự án'},
        {'name': 'Dự án con'},
      ],
      'dueDate': DateTime(2025, 4, 2),
    },
        {
      'title': 'Tàn canh gió lạnh',
      'status': 'Đang làm',
      'subTasks': [
        {'name': 'Đăng nhập'},
        {'name': 'Trang chủ'},
        {'name': 'Dự án'},
        {'name': 'Thêm dự án'},
        {'name': 'Dự án con'},
      ],
      'dueDate': DateTime(2025, 4, 3),
    },
    {
      'title': 'Tản canh gió lạnh',
      'status': 'Cần làm',
      'subTasks': List<Map<String, dynamic>>.from([
        {'name': 'Đăng nhập'},
        {'name': 'Trang chủ'},
        {'name': 'Dự án'},
      ]), // Chuyển về List<Map<String, dynamic>>
      'dueDate': DateTime(2025, 4, 4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTasks = tasks
        .where((task) =>
            task['dueDate'].year == selectedDate.year &&
            task['dueDate'].month == selectedDate.month &&
            task['dueDate'].day == selectedDate.day)
        .toList();

    return Expanded(
      child: filteredTasks.isEmpty
          ? const Center(child: Text("Không có công việc cho ngày này"))
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return TaskItemWidget(
                  title: task['title'],
                  status: task['status'],
                  subTasks: task['subTasks'],
                  dueDate: task['dueDate'],
                );
              },
            ),
    );
  }
}
