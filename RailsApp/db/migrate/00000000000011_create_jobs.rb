class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :count, index: true
      t.references :order, index: true
      t.integer :user_id
      t.integer :total_count
      t.string :type
      t.string :status
      t.datetime :queued_at
      t.datetime :working_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.datetime :killed_at

      t.timestamps
    end
  end
end

