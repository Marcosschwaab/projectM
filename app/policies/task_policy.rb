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

  def modal?
    show?
  end

  def move?
    update?
  end

  def bulk_update?
    user.member_of?(record.project.organization)
  end

  def bulk_destroy?
    user.role_in(record.project.organization).in?(%w[admin manager])
  end

  def destroy?
    user.role_in(record.project.organization).in?(%w[admin manager])
  end

  class Scope < Scope
    def resolve
      scope.joins(project: { organization: :memberships })
           .where(memberships: { user_id: user.id })
    end
  end
end
