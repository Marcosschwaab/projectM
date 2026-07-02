class CreateCustomFieldValues < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_field_values do |t|
      t.references :custom_field, null: false, foreign_key: true
      t.references :customizable, polymorphic: true, null: false
      t.text :value

      t.timestamps
    end
    add_index :custom_field_values, [:custom_field_id, :customizable_type, :customizable_id], unique: true, name: "idx_cfv_on_field_and_customizable"
  end
end
