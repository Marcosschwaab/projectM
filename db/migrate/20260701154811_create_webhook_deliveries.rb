class CreateWebhookDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_deliveries do |t|
      t.references :webhook, null: false, foreign_key: true
      t.integer :status
      t.text :response
      t.text :error

      t.timestamps
    end
  end
end
