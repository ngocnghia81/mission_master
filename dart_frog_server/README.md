# Mission Master API Server

API Server cho ứng dụng Mission Master sử dụng Dart Frog và PostgreSQL.

## Cấu trúc thư mục

```
dart_frog_server/
├── lib/
│   ├── config/
│   │   └── database_config.dart     # Cấu hình kết nối PostgreSQL
│   └── services/
│       └── database_service.dart    # Service để tương tác với PostgreSQL
├── routes/
│   ├── _middleware.dart             # Middleware để cung cấp DatabaseService
│   └── api/
│       ├── admin/                   # API cho Admin
│       ├── manager/                 # API cho Manager
│       └── employee/                # API cho Employee
└── pubspec.yaml                     # Dependencies
```

## Cài đặt

1. Cài đặt các dependencies:

```bash
cd dart_frog_server
dart pub get
```

2. Cấu hình kết nối PostgreSQL:

Mở file `lib/config/database_config.dart` và cập nhật thông tin kết nối:

```dart
static const String host = 'localhost';
static const int port = 5432;
static const String databaseName = 'mission_master';
static const String username = 'postgres';
static const String password = 'password';
```

## Chạy server

```bash
dart pub global activate dart_frog_cli
dart_frog dev
```

Server sẽ chạy tại địa chỉ: `http://localhost:8080`

## API Endpoints

### Admin

- `GET /api/admin/users` - Lấy danh sách người dùng
- `POST /api/admin/users` - Tạo người dùng mới

### Manager

- `GET /api/manager/projects` - Lấy danh sách dự án của manager
- `POST /api/manager/projects` - Tạo dự án mới

### Employee

- `GET /api/employee/tasks` - Lấy danh sách nhiệm vụ được giao cho employee

## Sử dụng DatabaseService

DatabaseService được cung cấp thông qua Provider trong Dart Frog. Bạn có thể sử dụng nó trong các route như sau:

```dart
Future<Response> onRequest(RequestContext context) async {
  final db = context.read<DatabaseService>();
  
  // Truy vấn dữ liệu
  final results = await db.query(
    'SELECT * FROM users WHERE role = @role',
    {'role': 'admin'},
  );
  
  return Response.json(body: results);
}
```

## Triển khai Repository Pattern với Dart Frog

Để triển khai Repository Pattern với Dart Frog, bạn có thể:

1. Tạo Provider cho các Repository trong `routes/_middleware.dart`:

```dart
Handler middleware(Handler handler) {
  return handler
    .use(provider<DatabaseService>((context) => DatabaseService()))
    .use(provider<UserRepository>((context) => PostgresUserRepository()))
    .use(provider<ProjectRepository>((context) => PostgresProjectRepository()))
    .use(provider<TaskRepository>((context) => PostgresTaskRepository()));
}
```

2. Sử dụng Repository trong các route:

```dart
Future<Response> onRequest(RequestContext context) async {
  final userRepository = context.read<UserRepository>();
  
  final users = await userRepository.getAll();
  return Response.json(body: users);
}
```

Cách này giúp bạn dễ dàng thay đổi implementation của Repository mà không ảnh hưởng đến code trong các route.
