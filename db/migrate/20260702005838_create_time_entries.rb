class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.integer :duration
      t.text :description

      t.timestamps
    end
    add_index :time_entries, :ended_at
    add_index :time_entries, [:task_id, :user_id]
    add_index :time_entries, [:user_id, :started_at]
  end
end
