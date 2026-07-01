class AddRecurrenceToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :recurrence_rule, :string
    add_column :tasks, :recurrence_end_date, :date
    add_reference :tasks, :recurring_parent, foreign_key: { to_table: :tasks }, index: true
  end
end
