class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.integer :priority, default: 0
      t.integer :status, default: 0
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :color, default: "#6366f1"
      t.string :icon, default: "folder"
      t.date :start_date
      t.date :end_date
      t.decimal :progress, precision: 5, scale: 2, default: 0.0
      t.references :organization, null: false, foreign_key: true
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end
