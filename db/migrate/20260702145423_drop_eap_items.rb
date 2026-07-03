class DropEapItems < ActiveRecord::Migration[8.1]
  def change
    drop_table :eap_items do |t|
      t.references :project, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :eap_items }
      t.string :name, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.date :start_date
      t.date :end_date
      t.references :responsible, foreign_key: { to_table: :users }
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
