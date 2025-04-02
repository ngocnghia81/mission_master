# Mission Master

Ứng dụng quản lý công việc nhóm được xây dựng bằng Flutter.

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
│   ├── tasks/              # Quản lý công việc
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
    -   `task.dart`: Model công việc
    -   `project.dart`: Model dự án
    -   `team.dart`: Model nhóm

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

## Database

Ứng dụng sử dụng SQLite với các bảng chính:

-   Users: Quản lý người dùng
-   Projects: Quản lý dự án
-   Tasks: Quản lý công việc
-   Teams: Quản lý nhóm
-   Comments: Quản lý bình luận
-   Attachments: Quản lý file đính kèm
