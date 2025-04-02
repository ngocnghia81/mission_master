# Mission Master

Ứng dụng quản lý dự án và nhiệm vụ cho công ty và làm việc nhóm, được xây dựng bằng Flutter.

## Cấu trúc thư mục

Dự án được tổ chức theo kiến trúc module với các thư mục chính sau:

```
lib/
├── core/                   # Thành phần cốt lõi của ứng dụng
│   ├── constants/          # Các hằng số toàn cục
│   ├── theme/              # Theme và màu sắc
│   ├── utils/              # Các hàm tiện ích
│   ├── services/           # Các service (database, network, v.v.)
│   └── models/             # Các model dữ liệu
│
├── features/               # Các tính năng của ứng dụng
│   ├── auth/               # Xác thực người dùng
│   ├── home/               # Màn hình chính
│   ├── projects/           # Quản lý dự án
│   ├── tasks/              # Quản lý nhiệm vụ
│   ├── evaluations/        # Đánh giá nhiệm vụ
│   ├── profile/            # Hồ sơ người dùng
│   └── settings/           # Cài đặt ứng dụng
│
├── shared/                 # Các thành phần dùng chung
│   ├── widgets/            # Các widget có thể tái sử dụng
│   └── providers/          # Các provider cho state management
│
└── config/                 # Cấu hình ứng dụng
```

## Hướng dẫn tổ chức code

### 1. Thư mục core/

-   **constants/**: Chứa các hằng số của ứng dụng

    -   `app_constants.dart`: Các hằng số toàn cục
    -   `api_constants.dart`: Các endpoint và cài đặt API
    -   `route_constants.dart`: Các route name cho navigation

-   **theme/**: Chứa các file liên quan đến giao diện

    -   `app_colors.dart`: Định nghĩa bảng màu của ứng dụng
    -   `app_theme.dart`: Cấu hình theme
    -   `text_styles.dart`: Các style cho text

-   **utils/**: Chứa các tiện ích dùng chung

    -   `date_utils.dart`: Xử lý ngày tháng
    -   `validators.dart`: Xác thực dữ liệu
    -   `logger.dart`: Ghi log

-   **services/**: Chứa các service

    -   `database_service.dart`: Quản lý kết nối database
    -   `auth_service.dart`: Xử lý xác thực
    -   `api_service.dart`: Xử lý API call

-   **models/**: Chứa các model dữ liệu
    -   `user.dart`: Model người dùng
    -   `project.dart`: Model dự án
    -   `project_membership.dart`: Model thành viên dự án
    -   `task.dart`: Model nhiệm vụ
    -   `evaluation.dart`: Model đánh giá
    -   `penalty.dart`: Model phạt

### 2. Thư mục features/

Mỗi feature nên chứa:

-   **screens/**: Các màn hình UI
-   **widgets/**: Các widget riêng của feature
-   **controllers/**: Logic xử lý
-   **repositories/**: Xử lý dữ liệu

Ví dụ cho feature tasks:

```
features/tasks/
├── screens/
│   ├── task_list_screen.dart
│   ├── task_detail_screen.dart
│   └── task_create_screen.dart
├── widgets/
│   ├── task_card.dart
│   └── priority_badge.dart
├── controllers/
│   └── task_controller.dart
└── repositories/
    └── task_repository.dart
```

### 3. Thư mục shared/

-   **widgets/**: Các widget dùng chung

    -   `custom_button.dart`
    -   `loading_indicator.dart`
    -   `error_dialog.dart`

-   **providers/**: Các provider cho state management
    -   `auth_provider.dart`
    -   `theme_provider.dart`

### 4. Thư mục config/

-   `app_config.dart`: Cấu hình chung cho ứng dụng
-   `route_config.dart`: Cấu hình routing
-   `dependencies.dart`: Cấu hình dependency injection

## Màu sắc chính

-   Primary Dark: `#022E39`
-   Primary Medium: `#044B55`
-   Primary Light: `#793F4E`
-   Accent: `#C0424E`
-   Highlight: `#D94B58`

## Cấu trúc Database

Ứng dụng sử dụng SQLite với các bảng sau:

### 1. Bảng users

Lưu trữ thông tin người dùng với các vai trò khác nhau.

-   **id**: Khóa chính, tự động tăng
-   **email**: Email đăng nhập, duy nhất
-   **username**: Tên đăng nhập, duy nhất
-   **password**: Mật khẩu (đã mã hóa)
-   **full_name**: Họ tên đầy đủ
-   **role**: Vai trò ('admin', 'manager', 'employee')
-   **avatar**: URL ảnh đại diện
-   **phone**: Số điện thoại
-   **is_active**: Trạng thái hoạt động (1/0)
-   **created_at**: Thời gian tạo
-   **updated_at**: Thời gian cập nhật gần nhất

### 2. Bảng projects

Lưu trữ thông tin về các dự án.

-   **id**: Khóa chính, tự động tăng
-   **name**: Tên dự án
-   **logo**: URL logo dự án
-   **description**: Mô tả dự án
-   **start_date**: Ngày bắt đầu
-   **end_date**: Ngày kết thúc
-   **status**: Trạng thái ('not_started', 'in_progress', 'completed', 'cancelled')
-   **manager_id**: ID của quản lý dự án (khóa ngoại đến users)
-   **leader_id**: ID của nhóm trưởng (khóa ngoại đến users)
-   **created_at**: Thời gian tạo
-   **updated_at**: Thời gian cập nhật gần nhất

### 3. Bảng project_memberships

Quản lý mối quan hệ giữa người dùng và dự án.

-   **id**: Khóa chính, tự động tăng
-   **user_id**: ID người dùng (khóa ngoại đến users)
-   **project_id**: ID dự án (khóa ngoại đến projects)
-   **created_at**: Thời gian thêm vào dự án

### 4. Bảng tasks

Lưu trữ thông tin về các nhiệm vụ.

-   **id**: Khóa chính, tự động tăng
-   **title**: Tiêu đề nhiệm vụ
-   **description**: Mô tả nhiệm vụ
-   **status**: Trạng thái ('not_assigned', 'in_progress', 'completed', 'overdue')
-   **priority**: Độ ưu tiên ('high', 'medium', 'low')
-   **start_date**: Ngày bắt đầu
-   **due_date**: Deadline
-   **completed_date**: Ngày hoàn thành
-   **project_id**: ID dự án (khóa ngoại đến projects)
-   **user_project_id**: ID liên kết người dùng-dự án (khóa ngoại đến project_memberships)
-   **assigned_by**: ID người giao việc (khóa ngoại đến users)
-   **is_penalty_applied**: Đã áp dụng phạt (1/0)
-   **created_at**: Thời gian tạo
-   **updated_at**: Thời gian cập nhật gần nhất

### 5. Bảng comments

Lưu trữ các bình luận trên nhiệm vụ.

-   **id**: Khóa chính, tự động tăng
-   **content**: Nội dung bình luận
-   **task_id**: ID nhiệm vụ (khóa ngoại đến tasks)
-   **user_id**: ID người bình luận (khóa ngoại đến users)
-   **created_at**: Thời gian tạo
-   **updated_at**: Thời gian cập nhật gần nhất

### 6. Bảng attachments

Lưu trữ thông tin về các file đính kèm.

-   **id**: Khóa chính, tự động tăng
-   **file_name**: Tên file
-   **file_path**: Đường dẫn đến file
-   **file_type**: Loại file
-   **task_id**: ID nhiệm vụ (khóa ngoại đến tasks)
-   **created_at**: Thời gian tải lên

### 7. Bảng evaluations

Lưu trữ đánh giá nhiệm vụ.

-   **id**: Khóa chính, tự động tăng
-   **task_id**: ID nhiệm vụ (khóa ngoại đến tasks)
-   **attitude_score**: Điểm thái độ làm việc (0-5)
-   **quality_score**: Điểm chất lượng công việc (0-5)
-   **evaluator_id**: ID người đánh giá (khóa ngoại đến users)
-   **notes**: Ghi chú đánh giá
-   **created_at**: Thời gian đánh giá

### 8. Bảng penalties

Lưu trữ thông tin về các hình phạt.

-   **id**: Khóa chính, tự động tăng
-   **task_id**: ID nhiệm vụ liên quan (khóa ngoại đến tasks)
-   **amount**: Số tiền phạt
-   **reason**: Lý do phạt
-   **is_paid**: Đã thanh toán (1/0)
-   **created_at**: Thời gian tạo

### 9. Bảng notifications

Lưu trữ thông báo cho người dùng.

-   **id**: Khóa chính, tự động tăng
-   **user_id**: ID người nhận thông báo (khóa ngoại đến users)
-   **title**: Tiêu đề thông báo
-   **message**: Nội dung thông báo
-   **type**: Loại thông báo (task, project, evaluation, etc.)
-   **related_id**: ID đối tượng liên quan
-   **is_read**: Đã đọc (1/0)
-   **created_at**: Thời gian tạo

## Mối quan hệ chính trong Database

1. **Quản lý Dự án**:

    - User (manager) quản lý nhiều Project
    - User tham gia nhiều Project thông qua bảng project_memberships
    - Project có một leader được chỉ định

2. **Quản lý Nhiệm vụ**:

    - Project chứa nhiều Task
    - Task được gán cho thành viên dự án (qua user_project_id)
    - User giao nhiệm vụ (assigned_by)

3. **Tương tác Nhiệm vụ**:

    - Task có nhiều Comment
    - Task có nhiều Attachment
    - Task có thể dẫn đến Penalty nếu trễ hạn

4. **Đánh giá và Thông báo**:
    - Task được đánh giá qua bảng Evaluation
    - User nhận nhiều Notification

## Vai trò và quyền hạn

### 1. Admin

-   Quản lý toàn bộ hệ thống
-   Cấp tài khoản cho quản lý
-   Xem báo cáo và thống kê toàn hệ thống

### 2. Quản lý

-   Tạo và quản lý dự án
-   Thêm nhân viên vào dự án
-   Chỉ định nhóm trưởng cho dự án
-   Xem báo cáo và thống kê của dự án

### 3. Nhân viên

-   Nhận và thực hiện nhiệm vụ
-   Có thể được chỉ định làm nhóm trưởng trong dự án
-   Nếu là nhóm trưởng: phân công nhiệm vụ, thiết lập deadline, đánh giá nhiệm vụ
-   Cập nhật trạng thái công việc
-   Trao đổi qua bình luận
-   Xem lịch trình và deadline

## Lưu ý

-   Nhóm trưởng được chỉ định trực tiếp trong bảng projects qua trường leader_id
-   Thành viên dự án được quản lý qua bảng project_memberships
-   Nhiệm vụ được gắn với thành viên dự án thông qua trường user_project_id trong bảng tasks
