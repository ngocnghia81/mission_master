# Database Schema - Mission Master

Đây là schema cơ sở dữ liệu PostgreSQL cho ứng dụng Mission Master.

## Cấu trúc thư mục

- `schema.sql`: Toàn bộ schema cơ sở dữ liệu
- `migrations/`: Các file migration riêng lẻ
  - `001_create_tables.sql`: Tạo các bảng
  - `002_create_indexes.sql`: Tạo các index và trigger
  - `003_seed_data.sql`: Dữ liệu mẫu

## Cách sử dụng

### Tạo cơ sở dữ liệu từ đầu

```bash
psql -f schema.sql
```

### Chạy từng migration

```bash
psql -d mission_master -f migrations/001_create_tables.sql
psql -d mission_master -f migrations/002_create_indexes.sql
psql -d mission_master -f migrations/003_seed_data.sql
```

## Mô hình dữ liệu

- **users**: Quản lý người dùng (admin, manager, employee)
- **projects**: Quản lý dự án
- **project_memberships**: Quản lý thành viên dự án
- **tasks**: Quản lý nhiệm vụ
- **comments**: Bình luận cho nhiệm vụ
- **attachments**: Tệp đính kèm cho dự án
- **evaluations**: Đánh giá nhiệm vụ
- **penalties**: Phạt cho nhiệm vụ trễ hạn
- **notifications**: Thông báo cho người dùng

## Kết nối từ Dart Frog

Trong dự án Dart Frog, bạn có thể sử dụng package `postgres` để kết nối:

```dart
// lib/services/database_service.dart
import 'package:postgres/postgres.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  PostgreSQLConnection? _connection;

  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && _connection!.isClosed == false) {
      return _connection!;
    }

    _connection = PostgreSQLConnection(
      'localhost', // host
      5432, // port
      'mission_master', // database name
      username: 'postgres', // username
      password: 'password', // password
    );

    await _connection!.open();
    return _connection!;
  }

  Future<void> close() async {
    if (_connection != null && _connection!.isClosed == false) {
      await _connection!.close();
    }
  }
}
```
