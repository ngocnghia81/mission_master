import 'package:flutter/material.dart';
import '../../core/models/task.dart';
import '../../services/api_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Sử dụng ApiService để lấy danh sách tasks
      final api = ApiService.instance;
      final tasksData = await api.getTasks(4); // Giả sử employeeId = 4

      // Chuyển đổi từ Map<String, dynamic> sang Task
      final tasks = tasksData.map((data) => Task.fromMap(data)).toList();

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading tasks: $e';
        _isLoading = false;
      });
      print('Error loading tasks: $e');
    }
  }

  Future<void> _addTask() async {
    try {
      final task = Task(
        title: 'New Task ${DateTime.now().millisecondsSinceEpoch}',
        status: 'pending',
        priority: 'medium',
        projectId: 1,
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sử dụng ApiService để tạo task mới
      final api = ApiService.instance;
      await api.createTask(task.toMap());

      // Tải lại danh sách tasks
      _loadTasks();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding task: $e';
      });
      print('Error adding task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(_errorMessage, textAlign: TextAlign.center),
                    ],
                  ),
                )
              : _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.task, size: 48),
                          const SizedBox(height: 16),
                          const Text('No tasks found'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addTask,
                            child: const Text('Add Task'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.status),
                          leading: Icon(
                            Icons.task,
                            color: task.priority == 'high'
                                ? Colors.red
                                : task.priority == 'medium'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
