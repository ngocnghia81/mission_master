class DatabaseConfig {
  static const String databaseName = 'mission_master.db';
  static const int databaseVersion = 1;

  // Table names
  static const String tableUsers = 'users';
  static const String tableTasks = 'tasks';
  static const String tableProjects = 'projects';
  static const String tableTeams = 'teams';
  static const String tableComments = 'comments';
  static const String tableAttachments = 'attachments';

  // Common column names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
}
