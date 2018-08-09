class CreateFtpUsers < ActiveRecord::Migration
  def view_name
    %w[development test].include?(Rails.env) ? '"ftp_users"' : '"ftp"."users"'
  end

  def up
    sql = load_sql(20150501092147, 'ftp_users')
    sql.sub!('"model".', '')  if %w[development test].include?(Rails.env)
    create_view view_name, sql
  end

  def down
    drop_view view_name
  end
end

