class CommentPolicy < ApplicationPolicy
  def create?
    user.can_access_project?(record.task.project)
  end

  def destroy?
    record.user == user || super_admin? || org_admin_or_manager? || user.project_manager?(record.task.project)
  end
end
