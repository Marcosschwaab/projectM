class ObjectivePolicy < ApplicationPolicy
  def create?
    user.role_in(record.okr_cycle.organization).in?(%w[admin manager])
  end

  def update?
    user.role_in(record.okr_cycle.organization).in?(%w[admin manager])
  end

  def edit?
    update?
  end

  def destroy?
    user.role_in(record.okr_cycle.organization).in?(%w[admin manager])
  end
end
