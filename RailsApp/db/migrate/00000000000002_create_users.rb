class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, index: { unique: true }
      t.string :password_digest
      t.string :remember_token, index: true
      t.string :activation_token
      t.string :status
      t.boolean :sysadmin
      t.integer :company_id
      t.boolean :admin
      t.integer :created_by, foreign_key: {references: :users}
      t.datetime :activation_expire_at

      t.timestamps
    end
  end
end

