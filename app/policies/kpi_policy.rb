class KpiPolicy < ApplicationPolicy
  def index?
    user.member_of?(record)
  end

  def show?
    user.member_of?(record.organization)
  end

  def create?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  def new?
    create?
  end

  def update?
    user.role_in(record.organization).in?(%w[admin manager])
  end

  def edit?
    update?
  end

  def destroy?
    user.role_in(record.organization).in?(%w[admin])
  end

  class Scope < Scope
    def resolve
      scope.joins(:organization)
           .where(organizations: { id: user.organization_ids })
    end
  end
end
