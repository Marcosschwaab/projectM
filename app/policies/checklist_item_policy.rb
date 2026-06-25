class ChecklistItemPolicy < ApplicationPolicy
  def create?
    user.member_of?(record.task.project.organization)
  end

  def update?
    user.member_of?(record.task.project.organization)
  end

  def destroy?
    user.member_of?(record.task.project.organization)
  end
end
