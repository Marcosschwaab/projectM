class CreateKeyResults < ActiveRecord::Migration[8.1]
  def change
    create_table :key_results do |t|
      t.references :objective, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :target_value, precision: 10, scale: 2
      t.decimal :current_value, precision: 10, scale: 2, default: 0.0
      t.string :unit
      t.decimal :progress, precision: 5, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
