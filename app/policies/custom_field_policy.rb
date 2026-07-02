class CustomFieldPolicy < ApplicationPolicy
  def create?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  def update?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  def destroy?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: user.organization_ids)
    end
  end
end
