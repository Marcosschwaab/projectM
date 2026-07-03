class EnhanceProjectsForRoles < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :category, :string
    add_reference :projects, :sponsor, foreign_key: { to_table: :users }
    add_reference :projects, :manager, foreign_key: { to_table: :users }
    add_column :projects, :approval_roles, :string, array: true, default: []
    add_column :projects, :approval_all_team, :boolean, default: false

    add_index :projects, :approval_roles, using: :gin
  end
end
