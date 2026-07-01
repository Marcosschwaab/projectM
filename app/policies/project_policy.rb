class ProjectPolicy < ApplicationPolicy
  def index?
    user.member_of?(record.organization)
  end

  def show?
    user.member_of?(record.organization)
  end

  def create?
    user.member_of?(record.organization)
  end

  def update?
    user.member_of?(record.organization)
  end

  def destroy?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  def archive?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  class Scope < Scope
    def resolve
      scope.joins(organization: :memberships)
           .where(memberships: { user_id: user.id })
    end
  end
end
