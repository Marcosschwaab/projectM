class TaskPolicy < ApplicationPolicy
  def index?
    task_project.present? && user.member_of?(task_project.organization)
  end

  def show?
    user.can_access_project?(task_project)
  end

  def create?
    user.can_access_project?(task_project)
  end

  def update?
    user.can_access_project?(task_project)
  end

  def modal?
    show?
  end

  def move?
    update?
  end

  def bulk_update?
    user.can_access_project?(task_project)
  end

  def bulk_destroy?
    super_admin? || org_admin_or_manager? || user.project_manager?(task_project)
  end

  def destroy?
    super_admin? || org_admin_or_manager? || user.project_manager?(task_project)
  end

  class Scope < Scope
    def resolve
      base = scope.joins(project: { organization: :memberships })
                  .where(organization_memberships: { user_id: user.id })

      if user.organization_memberships.where(role: [:super_admin, :admin, :manager]).exists? ||
         user.project_members.where(role: "manager").exists?
        base
      else
        base.where(project_id: user.project_members.select(:project_id))
      end
    end
  end

  private

  def task_project
    record.is_a?(Class) ? nil : record.project
  end
end
