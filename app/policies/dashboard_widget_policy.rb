class DashboardWidgetPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    record.user == user
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  def reorder?
    true
  end

  def permitted_attributes
    %i[widget_type position width visible settings]
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end
end
