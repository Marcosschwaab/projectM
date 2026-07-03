class CreateKanbanColumns < ActiveRecord::Migration[8.1]
  DEFAULT_COLUMNS = [
    { label: "Backlog",   status: "backlog",     color: "#6b7280" },
    { label: "To Do",     status: "todo",        color: "#6366f1" },
    { label: "In Progress", status: "in_progress", color: "#3b82f6" },
    { label: "In Review", status: "in_review",   color: "#8b5cf6" },
    { label: "Done",      status: "done",        color: "#10b981" },
  ].freeze

  def change
    create_table :kanban_columns do |t|
      t.references :project, null: false, foreign_key: true
      t.string :label, null: false
      t.string :status, null: false
      t.integer :position, null: false, default: 0
      t.string :color, null: false
      t.timestamps
    end

    add_index :kanban_columns, [:project_id, :position]

    reversible do |dir|
      dir.up do
        Project.find_each do |project|
          DEFAULT_COLUMNS.each_with_index do |col, index|
            project.kanban_columns.create!(
              label: col[:label],
              status: col[:status],
              position: index,
              color: col[:color]
            )
          end
        end
      end
    end
  end
end
