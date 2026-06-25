class TaskPolicy < ApplicationPolicy
  def index?
    user.member_of?(record.project.organization)
  end

  def show?
    user.member_of?(record.project.organization)
  end

  def create?
    user.member_of?(record.project.organization)
  end

  def update?
    user.member_of?(record.project.organization)
  end

  def destroy?
    user.role_in(record.project.organization).in?(%w[admin manager])
  end

  class Scope < Scope
    def resolve
      scope.joins(project: { organization: :organization_memberships })
           .where(organization_memberships: { user_id: user.id })
    end
  end
end
