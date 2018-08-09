require 'rails/generators/active_record/migration/migration_generator'

class ViewMigrationGenerator < ActiveRecord::Generators::MigrationGenerator

  VIEWS_DIRNAME = 'db/views'

  source_root File.expand_path('../templates', __FILE__)

  attr_reader :view_name

  def create_migration_file
    validate_file_name!
    set_local_assigns!

    migration_template @migration_template, view_migration_filename
    template "view_statement.sql", view_statement_file_name if @generate_sql
  end

  def last_sql_number
    last = Dir.glob("#{VIEWS_DIRNAME}/#{view_name}/[0-9]*_*.sql").map do |file|
      File.basename(file).split("_").first
    end.max
    last ||= "'[TIMESTAMP]'"
  end

  private
    def set_local_assigns!
      @migration_template = "view_migration.rb.erb"
      all, action, _view_name = *(/^([^_]+)_(.+)/.match(file_name))

      if['drop', 'create', 'alter'].include?(action)
        @view_name = normalize_view_name(_view_name)
        @migration_template = "#{action}_view_migration.rb.erb"
        @generate_sql = (['create', 'alter'].include?(action))
      end
    end

    def view_migration_filename
      "db/migrate/#{file_name}.rb"
    end

    def view_statement_file_name
      "#{VIEWS_DIRNAME}/#{view_name}/#{migration_number}_#{view_name}.sql"
    end

    def normalize_view_name(_view_name)
      pluralize_table_names? ? _view_name.pluralize : _view_name.singularize
    end

end

