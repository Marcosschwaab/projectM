class CreateCustomFields < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_fields do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :field_type, null: false, default: "text"
      t.jsonb :options, default: []
      t.boolean :required, default: false

      t.timestamps
    end
    add_index :custom_fields, [:organization_id, :name], unique: true
  end
end
