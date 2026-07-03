class AddEstimatedHoursToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :estimated_hours, :decimal, precision: 12, scale: 2, default: 0.0
  end
end
