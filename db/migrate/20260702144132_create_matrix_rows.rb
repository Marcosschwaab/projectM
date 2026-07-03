class CreateMatrixRows < ActiveRecord::Migration[8.1]
  def change
    create_table :matrix_rows do |t|
      t.references :project_matrix, null: false, foreign_key: true
      t.string :name, null: false, default: ""
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :matrix_rows, [:project_matrix_id, :position], unique: true
  end
end
