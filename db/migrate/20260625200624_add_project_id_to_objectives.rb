class AddProjectIdToObjectives < ActiveRecord::Migration[8.1]
  def change
    add_column :objectives, :project_id, :bigint
    add_index :objectives, :project_id
    add_foreign_key :objectives, :projects
  end
end
