class CreateChecklistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :checklist_items do |t|
      t.references :task, null: false, foreign_key: true
      t.string :content
      t.boolean :completed
      t.integer :position

      t.timestamps
    end
  end
end
