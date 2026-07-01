class CreateWebhooks < ActiveRecord::Migration[8.1]
  def change
    create_table :webhooks do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :url, null: false
      t.string :secret
      t.text :events, null: false, default: "--- []\n"
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
