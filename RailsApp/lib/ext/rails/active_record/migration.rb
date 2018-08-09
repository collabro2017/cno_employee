class ActiveRecord::Migration
  def load_sql(migration_number, view_name)
    sql_filename = "db/views/#{view_name}/#{migration_number}_#{view_name}.sql"
    File.read(Rails.root.join(sql_filename))
  end
end

