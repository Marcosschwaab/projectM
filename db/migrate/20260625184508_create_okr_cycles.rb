class CreateOkrCycles < ActiveRecord::Migration[8.1]
  def change
    create_table :okr_cycles do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :title
      t.date :start_date
      t.date :end_date
      t.integer :status

      t.timestamps
    end
  end
end
