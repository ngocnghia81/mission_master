-- Tạo tài khoản admin mặc định
INSERT INTO users (
    email, 
    username, 
    password, 
    full_name, 
    role, 
    is_active
) VALUES (
    'admin@missionmaster.com',
    'admin',
    '$2a$10$dPwdLKVUXdQwQIpAmpXMU.h8tQO38.yheF.zjcvxlsQARRXjWLIyu', -- 'admin123' đã được hash
    'System Administrator',
    'admin',
    TRUE
);

-- Tạo tài khoản manager mẫu
INSERT INTO users (
    email, 
    username, 
    password, 
    full_name, 
    role, 
    is_active
) VALUES (
    'manager@missionmaster.com',
    'manager',
    '$2a$10$dPwdLKVUXdQwQIpAmpXMU.h8tQO38.yheF.zjcvxlsQARRXjWLIyu', -- 'admin123' đã được hash
    'Project Manager',
    'manager',
    TRUE
);

-- Tạo tài khoản employee mẫu
INSERT INTO users (
    email, 
    username, 
    password, 
    full_name, 
    role, 
    is_active
) VALUES (
    'employee@missionmaster.com',
    'employee',
    '$2a$10$dPwdLKVUXdQwQIpAmpXMU.h8tQO38.yheF.zjcvxlsQARRXjWLIyu', -- 'admin123' đã được hash
    'Team Member',
    'employee',
    TRUE
);

-- Tạo dự án mẫu
INSERT INTO projects (
    name,
    description,
    start_date,
    end_date,
    status,
    manager_id
) VALUES (
    'Dự án mẫu',
    'Đây là dự án mẫu để kiểm tra hệ thống',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days',
    'in_progress',
    2
);

-- Thêm thành viên vào dự án
INSERT INTO project_memberships (
    user_id,
    project_id
) VALUES (
    3, -- employee
    1  -- Dự án mẫu
);

-- Tạo nhiệm vụ mẫu
INSERT INTO tasks (
    title,
    description,
    status,
    priority,
    start_date,
    due_days,
    membership_id
) VALUES (
    'Nhiệm vụ mẫu',
    'Đây là nhiệm vụ mẫu để kiểm tra hệ thống',
    'in_progress',
    'medium',
    CURRENT_TIMESTAMP,
    7,
    1  -- ID của project_membership
);

-- Tạo task_detail mẫu
INSERT INTO task_details (
    title,
    description,
    status,
    task_id
) VALUES (
    'Chi tiết nhiệm vụ mẫu',
    'Đây là chi tiết nhiệm vụ mẫu để kiểm tra hệ thống',
    'in_progress',
    1  -- ID của task
);
