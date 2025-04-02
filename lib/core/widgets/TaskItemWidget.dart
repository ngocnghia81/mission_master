import 'package:flutter/material.dart';

enum TaskStatus { pending, inProgress, completed }

class TaskItemWidget extends StatefulWidget {
  final String title;
  final String status;
  final List<Map<String, dynamic>> subTasks;
  final DateTime dueDate;

  TaskItemWidget({
    required this.title,
    required this.status,
    required this.subTasks,
    required this.dueDate,
  });

  @override
  _TaskItemWidgetState createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget> {
  bool _isExpanded = false;

  // Mỗi task con sẽ có trạng thái riêng biệt
  List<TaskStatus> _taskStatuses = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái task cho từng task con với trạng thái ban đầu là pending
    _taskStatuses = List.generate(widget.subTasks.length, (_) => TaskStatus.pending);
  }

  void _toggleTaskStatus(int index) {
    // Nếu trạng thái công việc chính là "Hủy" hoặc "Kết thúc" thì không thay đổi taskStatuses
    if (widget.status == 'Hủy' || widget.status == 'Kết thúc') {
      return;
    }

    setState(() {
      // Thay đổi trạng thái task con
      if (_taskStatuses[index] == TaskStatus.pending) {
        _taskStatuses[index] = TaskStatus.inProgress;
      } else if (_taskStatuses[index] == TaskStatus.inProgress) {
        _taskStatuses[index] = TaskStatus.completed;
      } else if (_taskStatuses[index] == TaskStatus.completed) {
        _taskStatuses[index] = TaskStatus.pending;
      }
    });
  }

  // Màu sắc cho status của task chính
  Color _getStatusColor() {
    switch (widget.status) {
      case 'Hủy':
        return Color(0xFFF4D6D9); // Màu khung
      case 'Đang làm':
        return Color(0xFFFFE9E1); // Màu khung
      case 'Cần làm':
        return Color(0xFFD5F1F1); // Màu khung
      case 'Kết thúc':
        return Color(0xFFC7CECF); // Màu khung
      default:
        return Colors.transparent; // Default
    }
  }

  Color _getTextColor() {
    switch (widget.status) {
      case 'Hủy':
        return Color(0xFFF15E75); // Màu chữ
      case 'Đang làm':
        return Color(0xFFFF9142); // Màu chữ
      case 'Cần làm':
        return Color(0xFF044855); // Màu chữ
      case 'Kết thúc':
        return Color(0xFF4C5555); // Màu chữ
      default:
        return Colors.black; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: ListTile(
              title: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text("Hạn chót: ${widget.dueDate.day}/${widget.dueDate.month}/${widget.dueDate.year}"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: _getStatusColor(), // Màu nền
                  borderRadius: BorderRadius.circular(12), // Bo góc
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.5), // Màu khung nhẹ
                  ),
                ),
                child: Text(
                  widget.status,
                  style: TextStyle(
                    color: _getTextColor(), // Màu chữ
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: widget.subTasks.asMap().entries.map((entry) {
                  int index = entry.key;
                  String subTask = entry.value['name'];

                  return ListTile(
                    leading: GestureDetector(
                      onTap: () => _toggleTaskStatus(index),
                      child: Icon(
                        _taskStatuses[index] == TaskStatus.completed
                            ? Icons.check_circle
                            : _taskStatuses[index] == TaskStatus.inProgress
                                ? Icons.sync
                                : Icons.radio_button_unchecked,
                        color: _taskStatuses[index] == TaskStatus.completed
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    title: Text(subTask),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
