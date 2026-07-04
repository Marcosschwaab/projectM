class ChecklistItemPolicy < ApplicationPolicy
  def create?
    user.can_access_project?(record.task.project)
  end

  def update?
    user.can_access_project?(record.task.project)
  end

  def destroy?
    user.can_access_project?(record.task.project)
  end
end
