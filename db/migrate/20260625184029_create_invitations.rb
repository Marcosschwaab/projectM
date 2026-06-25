class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :email
      t.string :token
      t.integer :role
      t.boolean :accepted
      t.datetime :expires_at

      t.timestamps
    end
  end
end
