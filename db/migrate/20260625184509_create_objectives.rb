class CreateObjectives < ActiveRecord::Migration[8.1]
  def change
    create_table :objectives do |t|
      t.references :okr_cycle, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.references :owner, foreign_key: { to_table: :users }
      t.decimal :progress, precision: 5, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
