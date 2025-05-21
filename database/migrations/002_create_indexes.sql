-- Tạo các index để tối ưu truy vấn
CREATE INDEX idx_projects_manager_id ON projects(manager_id);
CREATE INDEX idx_projects_leader_id ON projects(leader_id);
CREATE INDEX idx_project_memberships_user_id ON project_memberships(user_id);
CREATE INDEX idx_project_memberships_project_id ON project_memberships(project_id);
CREATE INDEX idx_tasks_membership_id ON tasks(membership_id);
CREATE INDEX idx_comments_task_id ON comments(task_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_attachments_project_id ON attachments(project_id);
CREATE INDEX idx_attachments_task_detail_id ON attachments(task_detail_id);
CREATE INDEX idx_evaluations_task_id ON evaluations(task_id);
CREATE INDEX idx_penalties_task_id ON penalties(task_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_task_details_task_id ON task_details(task_id);

-- Tạo các trigger để tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
BEFORE UPDATE ON projects
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at
BEFORE UPDATE ON comments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
