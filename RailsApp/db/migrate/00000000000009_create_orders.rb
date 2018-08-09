class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :count_id
      t.integer :user_id
      t.integer :total_cap
      t.string :ftp_url
      t.string :s3_url
      t.string :cap_type
      t.string :po_number

      t.timestamps
    end
  end
end

