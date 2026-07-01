class TaskDependency < ApplicationRecord
  belongs_to :task
  belongs_to :dependency, class_name: "Task"

  validates :dependency_id, uniqueness: { scope: :task_id }
  validate :not_self_referencing
  validate :no_circular_dependency

  private

  def not_self_referencing
    if task_id == dependency_id
      errors.add(:dependency, "cannot depend on itself")
    end
  end

  def no_circular_dependency
    return unless task_id && dependency_id
    if TaskDependency.where(task_id: dependency_id, dependency_id: task_id).exists?
      errors.add(:dependency, "circular dependency detected")
    end
  end
end
