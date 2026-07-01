class CreateDashboardWidgets < ActiveRecord::Migration[8.1]
  def change
    create_table :dashboard_widgets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :widget_type, null: false
      t.integer :position, null: false, default: 0
      t.jsonb :settings, default: {}
      t.integer :width, null: false, default: 1
      t.boolean :visible, null: false, default: true

      t.timestamps
    end
    add_index :dashboard_widgets, %i[user_id position], unique: true
  end
end
