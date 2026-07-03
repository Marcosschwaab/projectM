class CreateProjectMatrices < ActiveRecord::Migration[8.1]
  def change
    create_table :project_matrices do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false, default: ""

      t.timestamps
    end
    add_index :project_matrices, [:project_id, :name], unique: true
  end
end
