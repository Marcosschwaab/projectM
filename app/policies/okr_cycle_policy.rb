class OkrCyclePolicy < ApplicationPolicy
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

  class Scope < Scope
    def resolve
      scope.joins(organization: :organization_memberships)
           .where(organization_memberships: { user_id: user.id })
    end
  end
end
