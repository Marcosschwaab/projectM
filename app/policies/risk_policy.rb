class RiskPolicy < ApplicationPolicy
  def index?
    user.can_access_project?(record.project)
  end

  def show?
    user.can_access_project?(record.project)
  end

  def create?
    super_admin? || org_admin_or_manager? || user.project_manager?(record.project)
  end

  def new?
    create?
  end

  def update?
    super_admin? || org_admin_or_manager? || user.project_manager?(record.project)
  end

  def edit?
    update?
  end

  def destroy?
    super_admin? || org_admin?
  end

  class Scope < Scope
    def resolve
      base = scope.joins(project: { organization: :memberships })
                  .where(organization_memberships: { user_id: user.id })

      if user.organization_memberships.where(role: [:super_admin, :admin, :manager]).exists? ||
         user.project_members.where(role: "manager").exists?
        base
      else
        base.where(projects: { id: user.project_members.select(:project_id) })
      end
    end
  end
end