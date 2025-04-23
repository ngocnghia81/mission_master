enum UserRole {
  admin,
  manager,
  employee;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Quản lý';
      case UserRole.employee:
        return 'Nhân viên';
    }
  }

  String get value {
    return name;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.employee,
    );
  }
}

enum ProjectStatus {
  notStarted,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.notStarted:
        return 'Chưa bắt đầu';
      case ProjectStatus.inProgress:
        return 'Đang thực hiện';
      case ProjectStatus.completed:
        return 'Đã kết thúc';
      case ProjectStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get value {
    return name;
  }

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ProjectStatus.notStarted,
    );
  }
}

enum TaskStatus {
  notAssigned,
  inProgress,
  completed,
  overdue;

  String get displayName {
    switch (this) {
      case TaskStatus.notAssigned:
        return 'Chưa nhận';
      case TaskStatus.inProgress:
        return 'Đang thực hiện';
      case TaskStatus.completed:
        return 'Đã hoàn thành';
      case TaskStatus.overdue:
        return 'Trễ hạn';
    }
  }

  String get value {
    return name;
  }

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TaskStatus.notAssigned,
    );
  }
}

enum TaskPriority {
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case TaskPriority.high:
        return 'Cao';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.low:
        return 'Thấp';
    }
  }

  String get value {
    return name;
  }

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => TaskPriority.medium,
    );
  }
}
