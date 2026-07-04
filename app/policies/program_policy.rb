class ProgramPolicy < ApplicationPolicy
  def index?
    user.member_of?(organization)
  end

  def show?
    user.member_of?(organization)
  end

  def create?
    user.member_of?(organization)
  end

  def update?
    super_admin? || org_admin_or_manager?
  end

  def destroy?
    super_admin? || org_admin?
  end

  class Scope < Scope
    def resolve
      scope.joins(organization: :memberships)
           .where(organization_memberships: { user_id: user.id })
    end
  end
end
