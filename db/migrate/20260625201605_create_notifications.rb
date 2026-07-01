class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.references :notifiable, polymorphic: true
      t.references :organization, foreign_key: true
      t.boolean :read, default: false
      t.datetime :read_at
      t.timestamps
    end

    add_index :notifications, [ :recipient_id, :read ]
    add_index :notifications, :created_at
  end
end
