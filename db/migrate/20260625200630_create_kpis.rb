class CreateKpis < ActiveRecord::Migration[8.1]
  def change
    create_table :kpis do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.references :owner, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.text :description
      t.decimal :target_value, precision: 12, scale: 2
      t.decimal :current_value, precision: 12, scale: 2, default: 0.0
      t.string :unit
      t.integer :category, default: 0
      t.integer :frequency, default: 0
      t.integer :trend, default: 0
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :kpis, :category
    add_index :kpis, :frequency
  end
end
