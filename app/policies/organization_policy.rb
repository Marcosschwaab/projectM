class OrganizationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.member_of?(record)
  end

  def create?
    true
  end

  def update?
    user.role_in(record).in?(%w[admin manager])
  end

  def destroy?
    user.role_in(record) == "admin"
  end

  def manage_members?
    user.role_in(record).in?(%w[admin manager])
  end

  class Scope < Scope
    def resolve
      scope.joins(:memberships).where(memberships: { user_id: user.id })
    end
  end
end
