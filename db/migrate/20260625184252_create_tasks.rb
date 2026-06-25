class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.references :project, null: false, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.integer :priority, default: 0
      t.integer :status, default: 0
      t.date :due_date
      t.decimal :progress, precision: 5, scale: 2, default: 0.0
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
