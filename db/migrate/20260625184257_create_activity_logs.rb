class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.string :action
      t.references :trackable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.text :details
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
