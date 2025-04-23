import 'package:flutter/material.dart';

class TaskListWidget extends StatelessWidget {
  final DateTime selectedDate;

  const TaskListWidget({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Demo tasks - would normally be fetched from a database
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Họp nhóm dự án',
        'priority': 'high',
        'time': '09:00 - 10:30',
        'isCompleted': false,
      },
      {
        'title': 'Nộp báo cáo tuần',
        'priority': 'medium',
        'time': '13:00 - 14:00',
        'isCompleted': true,
      },
      {
        'title': 'Kiểm tra tiến độ',
        'priority': 'low',
        'time': '15:30 - 16:30',
        'isCompleted': false,
      },
    ];

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhiệm vụ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getPriorityColor(task['priority']),
                        radius: 5,
                      ),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          decoration: task['isCompleted']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(task['time']),
                      trailing: Checkbox(
                        value: task['isCompleted'],
                        onChanged: (value) {
                          // Update task status in real app
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
        return Colors.blue;
    }
  }
}
