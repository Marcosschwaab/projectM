class AddProjectIdToActivityLogs < ActiveRecord::Migration[8.1]
  def change
    add_reference :activity_logs, :project, null: true, foreign_key: true
  end
end
