class WebhookPolicy < ApplicationPolicy
  def show?
    user.member_of?(record.organization)
  end

  def create?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  def update?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  def destroy?
    user.role_in(record.organization).in?(%w[admin])
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: user.organization_ids)
    end
  end
end
