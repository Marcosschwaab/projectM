class CommentPolicy < ApplicationPolicy
  def create?
    user.member_of?(record.task.project.organization)
  end
end
