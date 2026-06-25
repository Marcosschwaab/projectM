class StrategicCanvasPolicy < ApplicationPolicy
  def show?
    user.member_of?(record.project.organization)
  end

  def update?
    user.member_of?(record.project.organization)
  end

  class Scope < Scope
    def resolve
      scope.joins(project: { organization: :organization_memberships })
           .where(organization_memberships: { user_id: user.id })
    end
  end
end
