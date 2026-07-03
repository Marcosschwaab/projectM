class ConvertTaskStatusToString < ActiveRecord::Migration[8.1]
  def up
    change_column :tasks, :status, :string, default: "backlog", using: "CASE status WHEN 0 THEN 'backlog' WHEN 1 THEN 'todo' WHEN 2 THEN 'in_progress' WHEN 3 THEN 'in_review' WHEN 4 THEN 'done' ELSE 'backlog' END"
  end

  def down
    change_column :tasks, :status, :integer, default: 0, using: "CASE status WHEN 'backlog' THEN 0 WHEN 'todo' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'in_review' THEN 3 WHEN 'done' THEN 4 ELSE 0 END"
  end
end
