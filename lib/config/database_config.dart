/// Cấu hình cơ sở dữ liệu cho ứng dụng Flutter
class DatabaseConfig {
  // Tên bảng
  static const String tableUsers = 'users';
  static const String tableProjects = 'projects';
  static const String tableProjectMemberships = 'project_memberships';
  static const String tableTasks = 'tasks';
  static const String tableComments = 'comments';
  static const String tableAttachments = 'attachments';
  static const String tableEvaluations = 'evaluations';
  static const String tablePenalties = 'penalties';
  static const String tableNotifications = 'notifications';
  
  // Tên cột chung
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  
  // Cấu hình PostgreSQL
  static const String host = 'localhost';
  static const int port = 5432;
  static const String database = 'mission_master';
  static const String username = 'postgres';
  static const String password = '';
}
