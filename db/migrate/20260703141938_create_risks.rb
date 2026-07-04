class CreateRisks < ActiveRecord::Migration[8.1]
  def change
    create_table :risks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :probability, null: false, default: 1
      t.integer :impact, null: false, default: 1
      t.string :status, null: false, default: "identified"
      t.text :mitigation_plan
      t.text :contingency_plan
      t.references :owner, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :risks, :status
    add_index :risks, %i[project_id status]
  end
end