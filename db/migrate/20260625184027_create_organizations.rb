class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :description
      t.boolean :allow_auto_join

      t.timestamps
    end
  end
end
