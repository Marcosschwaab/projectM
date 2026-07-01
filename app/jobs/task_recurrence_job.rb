class TaskRecurrenceJob < ApplicationJob
  queue_as :default

  def perform
    Task.recurring_active.find_each do |task|
      next unless task.due_date.present?
      next if task.recurring_parent.present?

      next_due = task.next_due_date
      next if next_due.nil?
      next if next_due > 30.days.from_now.to_date
      next if task.recurring_children.exists?(due_date: next_due)

      clone = task.dup
      clone.assign_attributes(
        due_date: next_due,
        recurrence_rule: nil,
        recurrence_end_date: nil,
        recurring_parent: task,
        status: :backlog,
        position: nil,
        created_at: Time.current,
        updated_at: Time.current
      )
      clone.save!

      task.tags.each { |tag| clone.tags << tag unless clone.tags.include?(tag) }
    end
  end
end
