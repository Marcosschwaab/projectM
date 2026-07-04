class TimeEntryPolicy < ApplicationPolicy
  def create?
    user.can_access_project?(record.task.project)
  end

  def start?
    user.can_access_project?(record.task.project)
  end

  def stop?
    user.can_access_project?(record.task.project)
  end

  def update?
    user.can_access_project?(record.task.project)
  end

  def destroy?
    user.can_access_project?(record.task.project)
  end
end
