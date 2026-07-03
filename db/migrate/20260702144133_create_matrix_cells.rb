class CreateMatrixCells < ActiveRecord::Migration[8.1]
  def change
    create_table :matrix_cells do |t|
      t.references :matrix_column, null: false, foreign_key: true
      t.references :matrix_row, null: false, foreign_key: true
      t.text :value, default: ""

      t.timestamps
    end
    add_index :matrix_cells, [:matrix_column_id, :matrix_row_id], unique: true
  end
end
