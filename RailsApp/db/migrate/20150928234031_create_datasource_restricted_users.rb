class CreateDatasourceRestrictedUsers < ActiveRecord::Migration
  def up
    create_view :datasource_restricted_users, load_sql(20150928234031, 'datasource_restricted_users')
  end

  def down
    drop_view :datasource_restricted_users
  end
end

