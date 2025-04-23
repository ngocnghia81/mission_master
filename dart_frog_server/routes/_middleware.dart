import 'package:dart_frog/dart_frog.dart';
import '../lib/services/database_service.dart';

/// Middleware cho tất cả các routes
/// Cung cấp DatabaseService cho tất cả các route
Handler middleware(Handler handler) {
  return handler.use(
    provider<DatabaseService>(
      (context) => DatabaseService(),
    ),
  );
}
