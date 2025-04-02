class DatabaseConfig {
  static const String databaseName = 'mission_master.db';
  static const int databaseVersion = 1;

  // Table names
  static const String tableUsers = 'users';
  static const String tableProjects = 'projects';
  static const String tableTasks = 'tasks';
  static const String tableTeams = 'teams';
  static const String tableComments = 'comments';
  static const String tableAttachments = 'attachments';
  static const String tableEvaluations = 'evaluations';
  static const String tableUserProjects = 'user_projects';
  static const String tableNotifications = 'notifications';
  static const String tablePenalties = 'penalties';
  static const String tableTaskHistory = 'task_history';
  static const String tableRewards = 'rewards';

  // Common column names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
}
