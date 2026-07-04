class ProjectPolicy < ApplicationPolicy
  def index?
    user.member_of?(organization)
  end

  def show?
    user.can_access_project?(record)
  end

  def create?
    user.member_of?(organization)
  end

  def update?
    super_admin? || org_admin_or_manager? || user.project_manager?(record)
  end

  def destroy?
    super_admin? || org_admin?
  end

  def archive?
    super_admin? || org_admin_or_manager?
  end

  def manage_members?
    super_admin? || org_admin_or_manager? || user.project_manager?(record)
  end

  class Scope < Scope
    def resolve
      base = scope.joins(organization: :memberships)
                  .where(organization_memberships: { user_id: user.id })

      if user.organization_memberships.where(role: [:super_admin, :admin, :manager]).exists? ||
         user.project_members.where(role: "manager").exists?
        base
      else
        base.where(id: user.project_members.select(:project_id))
      end
    end
  end
end
