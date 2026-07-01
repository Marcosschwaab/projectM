class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :color, default: "#6366f1"
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tags, [ :organization_id, :name ], unique: true
  end
end
