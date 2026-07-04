class CreatePrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :programs do |t|
      t.string :name, null: false
      t.text :description
      t.string :color
      t.string :icon
      t.string :status, default: "on_track"
      t.date :start_date
      t.date :end_date
      t.decimal :budget, precision: 15, scale: 2
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :programs, %i[organization_id name], unique: true
  end
end
