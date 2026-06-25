class StrategicCanvasPolicy < ApplicationPolicy
  def show?
    user.member_of?(record.project.organization)
  end

  def update?
    user.member_of?(record.project.organization)
  end

  class Scope < Scope
    def resolve
      scope.joins(project: { organization: :memberships })
           .where(memberships: { user_id: user.id })
    end
  end
end
