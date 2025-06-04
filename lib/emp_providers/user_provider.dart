// lib/providers/user_provider.dart
// users - evaluations - notifications
import 'package:flutter/material.dart';
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/models/evaluation.dart';
import 'package:mission_master/core/models/notification.dart'
    as app_notification;
import 'package:mission_master/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  int? userId; // Nhận từ bên ngoài
  User? _currentUser;
  Evaluation? _currentEvaluation;
  List<app_notification.Notification> _notifications = [];

  User? get currentUser => _currentUser;
  List<app_notification.Notification> get notifications => _notifications;

  void setUserId(int id) {
    userId = id;
    notifyListeners(); // để ProxyProvider biết có thay đổi
  }

  Future<void> init(int userId) async {
    this.userId = userId;
    await loadUserData();
  }

  Future<void> loadUserData() async {
    if (userId == null) return;
    try {
      final userData = await _api.getCurrentUser(userId!);
      _currentUser = User.fromMap(userData);

      final notifyData = await _api.getNotificationsByUserId(userId!);
      _notifications = notifyData
          .map((e) => app_notification.Notification.fromMap(e))
          .toList();

      notifyListeners();
      print('User data loaded successfully');
    } catch (e) {
      print('Lỗi khi load dữ liệu: $e');
      rethrow;
    }
  }
}
