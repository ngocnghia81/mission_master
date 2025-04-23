# Hướng Dẫn Phát Triển Dự Án Mission Master

Tài liệu này cung cấp hướng dẫn chi tiết về cách thiết lập, chạy và phát triển dự án Mission Master, đặc biệt tập trung vào việc quản lý mã nguồn cho 3 nhà phát triển làm việc trên 3 vai trò khác nhau (Admin, Manager, Employee).

## Mục Lục

1. [Cấu Trúc Dự Án](#cấu-trúc-dự-án)
2. [Thiết Lập Môi Trường](#thiết-lập-môi-trường)
3. [Chạy Dự Án](#chạy-dự-án)
4. [Quy Trình Git và Quản Lý Nhánh](#quy-trình-git-và-quản-lý-nhánh)
5. [Chiến Lược Tránh Xung Đột (Conflict)](#chiến-lược-tránh-xung-đột-conflict)
6. [Quản Lý File Cấu Hình](#quản-lý-file-cấu-hình)
7. [Quy Tắc Coding](#quy-tắc-coding)
8. [Quy Trình Review Code](#quy-trình-review-code)

## Cấu Trúc Dự Án

Dự án Mission Master được chia thành hai phần chính:

1. **Flutter App**: Ứng dụng di động cho người dùng cuối
2. **Dart Frog Server**: API server phục vụ ứng dụng

### Cấu trúc thư mục chính:

```
mission_master/
├── lib/                      # Mã nguồn Flutter app
│   ├── core/                 # Core components
│   │   ├── models/           # Data models
│   │   ├── repositories/     # Repository pattern implementation
│   │   └── ...
│   ├── features/             # Phân chia theo tính năng
│   │   ├── admin/            # Tính năng cho Admin
│   │   ├── manager/          # Tính năng cho Manager
│   │   └── employee/         # Tính năng cho Employee
│   └── services/             # Các service (API, Database)
├── dart_frog_server/         # Mã nguồn Dart Frog server
│   ├── lib/                  # Server-side logic
│   │   ├── models/           # Server-side models
│   │   ├── repositories/     # Server-side repositories
│   │   └── services/         # Server-side services
│   └── routes/               # API endpoints
│       ├── api/
│       │   ├── admin/        # Admin API endpoints
│       │   ├── manager/      # Manager API endpoints
│       │   └── employee/     # Employee API endpoints
└── ...
```

## Thiết Lập Môi Trường

### Yêu cầu:

- Flutter SDK (phiên bản >=3.0.6)
- Dart SDK (phiên bản >=3.0.0)
- PostgreSQL (đã cài đặt và chạy)
- Git

### Bước thiết lập:

1. **Clone repository:**

```bash
git clone <repository-url>
cd mission_master
```

2. **Cài đặt dependencies cho Flutter app:**

```bash
flutter pub get
```

3. **Cài đặt dependencies cho Dart Frog server:**

```bash
cd dart_frog_server
dart pub get
```

4. **Thiết lập PostgreSQL:**

- Tạo database mới cho dự án
- Cập nhật thông tin kết nối trong file cấu hình của server

5. **Thiết lập biến môi trường:**

Tạo file `.env` trong thư mục `dart_frog_server` với nội dung:

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mission_master
DB_USERNAME=your_username
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
```

## Chạy Dự Án

### Chạy Dart Frog Server:

```bash
cd dart_frog_server
dart_frog dev
```

Server sẽ chạy mặc định tại `http://localhost:8080`

### Chạy Flutter App:

```bash
# Từ thư mục gốc của dự án
flutter run
```

## Quy Trình Git và Quản Lý Nhánh

### Chiến lược nhánh:

Chúng ta sẽ sử dụng mô hình Git Flow đơn giản hóa:

1. **main**: Nhánh chính, chứa code sản phẩm ổn định
2. **develop**: Nhánh phát triển, tích hợp các tính năng mới
3. **feature/[role]/[feature-name]**: Nhánh tính năng, phân chia theo vai trò

### Quy trình làm việc:

1. **Khởi tạo nhánh mới từ develop:**

```bash
git checkout develop
git pull
git checkout -b feature/admin/user-management  # Ví dụ cho developer làm về Admin
git checkout -b feature/manager/project-creation  # Ví dụ cho developer làm về Manager
git checkout -b feature/employee/task-tracking  # Ví dụ cho developer làm về Employee
```

2. **Commit thường xuyên với mô tả rõ ràng:**

```bash
git add .
git commit -m "[Admin] Thêm chức năng quản lý người dùng"
```

3. **Cập nhật từ nhánh develop thường xuyên:**

```bash
git checkout develop
git pull
git checkout feature/admin/user-management
git merge develop
# Giải quyết conflict nếu có
```

4. **Tạo Pull Request:**
   - Khi hoàn thành tính năng, tạo Pull Request từ nhánh feature vào nhánh develop
   - Yêu cầu ít nhất 1 người review code
   - Chỉ merge khi đã được approve

## Chiến Lược Tránh Xung Đột (Conflict)

### 1. Phân chia code theo vai trò rõ ràng:

- **Admin Developer**: Làm việc chủ yếu trong thư mục `features/admin` và `routes/api/admin`
- **Manager Developer**: Làm việc chủ yếu trong thư mục `features/manager` và `routes/api/manager`
- **Employee Developer**: Làm việc chủ yếu trong thư mục `features/employee` và `routes/api/employee`

### 2. Sử dụng Repository Pattern:

Repository pattern đã được triển khai trong dự án để tách biệt logic truy cập dữ liệu. Mỗi developer nên:

- Tạo repository riêng cho các entity mới
- Mở rộng từ `BaseRepository` đã có
- Tránh sửa đổi trực tiếp các repository đang được sử dụng bởi developer khác

```dart
// Ví dụ về cách tạo repository mới
class NewFeatureRepository extends BaseRepository {
  // Implement các phương thức cụ thể
}
```

### 3. Quy tắc làm việc với file dùng chung:

- **Thông báo trước**: Khi cần sửa đổi file dùng chung (models, services, utils), thông báo cho team
- **Pull Request riêng**: Tạo PR riêng cho các thay đổi ở file dùng chung
- **Tách biệt logic**: Sử dụng interface và abstract class để tách biệt implementation

### 4. Chiến lược merge:

- Merge develop vào nhánh feature thường xuyên (ít nhất mỗi ngày)
- Giải quyết conflict ở nhánh feature, không phải ở develop
- Sử dụng `git rebase` thay vì `git merge` khi có thể để giữ lịch sử commit sạch sẽ

## Quy Tắc Coding

### 1. Tuân thủ style guide:

- Sử dụng `flutter_lints` và `very_good_analysis` để đảm bảo code chất lượng
- Chạy `flutter analyze` trước khi commit

### 2. Đặt tên rõ ràng:

- **Tên class**: PascalCase (ví dụ: `UserRepository`)
- **Tên biến và hàm**: camelCase (ví dụ: `getUserById`)
- **Tên hằng số**: SCREAMING_SNAKE_CASE (ví dụ: `API_BASE_URL`)

### 3. Comment và Documentation:

- Thêm docstring cho tất cả các class và method public
- Giải thích logic phức tạp bằng comment

```dart
/// Lấy danh sách người dùng theo vai trò.
///
/// [role] là vai trò cần lọc (admin, manager, employee).
/// Trả về danh sách [User] hoặc throw [Exception] nếu có lỗi.
Future<List<User>> getUsersByRole(String role) async {
  // Implementation
}
```

### 4. Xử lý lỗi:

- Luôn xử lý các exception
- Sử dụng try-catch trong các hàm async
- Trả về message lỗi rõ ràng

## Quản Lý File Cấu Hình

Để tránh xung đột khi nhiều người cùng làm việc trên dự án, chúng ta sẽ quản lý các file cấu hình như sau:

### 1. Nguyên tắc chung:

- **Không commit file cấu hình cá nhân**: Các file cấu hình chứa thông tin cá nhân (database credentials, API keys) không nên được commit lên repository
- **Sử dụng file template**: Mỗi file cấu hình cần có một file template tương ứng được commit lên repository
- **Sử dụng .gitignore**: Các file cấu hình cá nhân được thêm vào .gitignore để tránh vô tình commit

### 2. Quy trình thiết lập cấu hình:

Khi clone repository hoặc pull về các thay đổi mới, thực hiện các bước sau:

```bash
# Chạy script thiết lập cấu hình
cd dart_frog_server
dart scripts/setup_config.dart
```

Script này sẽ:
- Kiểm tra xem file cấu hình đã tồn tại chưa
- Nếu chưa, sẽ tạo file cấu hình từ template
- Sau đó bạn cần chỉnh sửa file cấu hình theo môi trường cá nhân

### 3. Các file cấu hình cần quản lý:

- **Database config**: `dart_frog_server/lib/config/database_config.dart`
  - Template: `dart_frog_server/lib/config/database_config.template.dart`
  - Chứa thông tin kết nối database (host, port, username, password)

- **Environment variables**: `.env` files
  - Template: `.env.example`
  - Chứa các biến môi trường như API keys, secrets

### 4. Khi cần thay đổi cấu hình:

Nếu cần thay đổi cấu trúc của file cấu hình (thêm field mới, thay đổi logic):

1. Thay đổi file template trước
2. Commit file template lên repository
3. Thông báo cho team về thay đổi
4. Mỗi thành viên sẽ cập nhật file cấu hình cá nhân của họ

Quy trình này giúp đảm bảo mỗi thành viên trong team có thể có cấu hình riêng phù hợp với môi trường phát triển cá nhân mà không gây xung đột khi pull code.

## Quy Trình Review Code

### 1. Checklist review:

- Code có tuân thủ style guide không?
- Có test cho các tính năng mới không?
- Có xử lý lỗi đầy đủ không?
- Có tối ưu hiệu suất không?
- Có tái sử dụng code thay vì copy-paste không?

### 2. Quy trình review:

- Mỗi PR cần ít nhất 1 người review
- Người review phải kiểm tra code chạy được trước khi approve
- Sử dụng comment trên GitHub để thảo luận về code
- Giải quyết tất cả comment trước khi merge

---

## Tổng Kết

Bằng cách tuân thủ hướng dẫn này, team 3 người có thể làm việc hiệu quả trên cùng một dự án mà không gặp nhiều xung đột. Điểm quan trọng nhất là:

1. **Phân chia rõ ràng trách nhiệm** theo vai trò (Admin, Manager, Employee)
2. **Sử dụng Repository Pattern** để tách biệt logic truy cập dữ liệu
3. **Giao tiếp thường xuyên** về các thay đổi ảnh hưởng đến phần code dùng chung
4. **Merge thường xuyên** từ develop vào nhánh feature để giảm thiểu conflict

Chúc team phát triển dự án thành công trong thời gian 1 tuần!
