class AddColumnAuthCodeInUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_code, :string
    add_column :users, :auth_token, :string    
  end
end
