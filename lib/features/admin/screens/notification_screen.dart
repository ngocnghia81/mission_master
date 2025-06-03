import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/features/admin/widgets/admin_app_bar.dart';
import 'package:mission_master/features/admin/widgets/admin_drawer.dart';
import 'package:intl/intl.dart';

class NotificationItem {
  final String id;
  final String content;
  final String sender;
  final DateTime dateTime;
  final String projectName;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.content,
    required this.sender,
    required this.dateTime,
    required this.projectName,
    this.isRead = false,
    required this.type,
  });
}

enum NotificationType {
  newProject,
  projectApproval,
  taskAssignment,
  taskCompletion,
  projectUpdate
}

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Giả lập tải thông báo từ API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _notifications = [
        NotificationItem(
          id: '1',
          content: 'vừa mới góp ý vào dự án',
          sender: 'Hà Huỳnh Anh Ngân',
          dateTime: DateTime.now(),
          projectName: 'Tản canh gió lạnh',
          type: NotificationType.projectUpdate,
        ),
        NotificationItem(
          id: '2',
          content: 'cần dền hạn của công việc',
          sender: 'Tản canh gió lạnh',
          dateTime: DateTime.now(),
          projectName: 'Thiết kế Figma-Nhân viên',
          type: NotificationType.projectUpdate,
        ),
        NotificationItem(
          id: '3',
          content: 'công việc "Thiết kế Figma-Quản lý" đã được duyệt',
          sender: 'Tản canh gió lạnh',
          dateTime: DateTime.now(),
          projectName: '',
          type: NotificationType.projectApproval,
        ),
        NotificationItem(
          id: '4',
          content: 'vừa phân công việc "Thiết kế Figma-Nhân viên" cho bạn',
          sender: 'Hà Huỳnh Anh Ngân',
          dateTime: DateTime.now().subtract(const Duration(days: 7)),
          projectName: '',
          type: NotificationType.taskAssignment,
        ),
        NotificationItem(
          id: '5',
          content: 'đã được giao cho nhóm',
          sender: 'Tản canh gió lạnh',
          dateTime: DateTime.now().subtract(const Duration(days: 7)),
          projectName: 'Lập trình',
          type: NotificationType.taskAssignment,
        ),
      ];
      _isLoading = false;
    });
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((notification) => notification.id == id);
      if (index != -1) {
        // Trong thực tế, bạn sẽ gọi API để đánh dấu thông báo đã đọc
        // và sau đó cập nhật state
        _notifications[index] = NotificationItem(
          id: _notifications[index].id,
          content: _notifications[index].content,
          sender: _notifications[index].sender,
          dateTime: _notifications[index].dateTime,
          projectName: _notifications[index].projectName,
          isRead: true,
          type: _notifications[index].type,
        );
      }
    });
  }

  Map<String, List<NotificationItem>> _groupNotificationsByDate() {
    final Map<String, List<NotificationItem>> grouped = {};
    
    for (var notification in _notifications) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final notificationDate = DateTime(
        notification.dateTime.year,
        notification.dateTime.month,
        notification.dateTime.day,
      );
      
      final difference = today.difference(notificationDate).inDays;
      
      String key;
      if (difference == 0) {
        key = 'Hôm nay (${_notifications.where((n) => 
          DateTime(n.dateTime.year, n.dateTime.month, n.dateTime.day) == 
          DateTime(now.year, now.month, now.day)).length})';
      } else if (difference <= 7) {
        key = '7 ngày qua';
      } else if (difference <= 30) {
        key = '30 ngày qua';
      } else {
        key = 'Cũ hơn';
      }
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      
      grouped[key]!.add(notification);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: AdminDrawer(onLogout: _handleLogout),
      appBar: AdminAppBar(
        title: 'Thông báo',
        showDrawerButton: true,
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationList(groupedNotifications),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông báo mới sẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(Map<String, List<NotificationItem>> groupedNotifications) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Danh sách thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...groupedNotifications.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...entry.value.map((notification) => _buildNotificationCard(notification)),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, color: Colors.grey),
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            children: [
              TextSpan(
                text: notification.sender,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' ${notification.content}'),
              if (notification.projectName.isNotEmpty)
                TextSpan(
                  text: ' "${notification.projectName}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _markAsRead(notification.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Kiểm tra',
            style: TextStyle(color: Colors.white),
          ),
        ),
        onTap: () {
          // Xử lý khi nhấn vào thông báo
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Điều hướng dựa vào loại thông báo
    switch (notification.type) {
      case NotificationType.newProject:
        // Điều hướng đến trang chi tiết dự án mới
        break;
      case NotificationType.projectApproval:
        // Điều hướng đến trang phê duyệt dự án
        break;
      case NotificationType.taskAssignment:
        // Điều hướng đến trang chi tiết nhiệm vụ
        break;
      case NotificationType.taskCompletion:
        // Điều hướng đến trang xem nhiệm vụ đã hoàn thành
        break;
      case NotificationType.projectUpdate:
        // Điều hướng đến trang cập nhật dự án
        break;
    }
  }
} 