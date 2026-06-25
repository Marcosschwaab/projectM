class CreateStrategicCanvases < ActiveRecord::Migration[8.1]
  def change
    create_table :strategic_canvases do |t|
      t.references :project, null: false, foreign_key: true
      t.text :problem
      t.text :goal
      t.text :value_proposition
      t.text :stakeholders
      t.text :team
      t.text :metrics
      t.text :risks
      t.text :resources
      t.text :roadmap
      t.text :next_steps

      t.timestamps
    end
  end
end
