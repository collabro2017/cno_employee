require 'securerandom'
require_relative 'database_connection'
require_relative 'configuration'
require 'pry'

class DbOperations

  @@central_ds = DatabaseConnection['central_datastore']
  @@node_ds    = DatabaseConnection['node_datastore']


  BINARY = 1

  # Selected values ------------------------------------------------------------
  def self.get_selected_value_ids(select_struct, field_values_table_name, criteria)
    generator = SqlCode::Generator.new(payload: nil)

    sql = generator.get_selected_value_ids_sql(
            select_struct,field_values_table_name, criteria
          )

    @@central_ds[sql].select_map(:id)
  end

  def self.get_selected_value_ids_as_bit_string(
    select_struct, field_values_table_name, criteria, total_records
  )
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.get_selected_value_ids_sql(
            select_struct, 
            field_values_table_name,
            criteria
          )
    get_query_result_ids_as_bit_string(total_records, @@central_ds, sql)
  end

  def self.drop_selected_values_ids_table(table_name)
    drop_table(
      db_connection: @@node_ds,
      table_name: table_name
    )
  end


  def self.insert_in_selected_value_ids_table_from_binary_string(
    table_name, binary_string, offset
  )
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.insert_in_selected_value_ids_table_from_binary_string_sql(
            table_name,offset
          )
    
    param = {value: binary_string, format: BINARY}

    @@node_ds.synchronize do |conn|
      conn.exec_params(sql, [param])
    end
  end

  #-----------------------------------------------------------------------------

  # Selected records -----------------------------------------------------------
  def self.selected_record_ids_as_bit_string(payload)
    sql = SqlCode::Generator.new(payload: payload).selected_record_ids_sql
    query_result_ids_as_bit_string(payload, @@node_ds, sql)
  end

  def self.get_selected_record_ids_as_bit_string(
    node_selected_value_ids_table_name, node_field_table_name, total_records
  )
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.get_selected_record_ids_sql(
            node_selected_value_ids_table_name, node_field_table_name
          )
    get_query_result_ids_as_bit_string(total_records, @@node_ds, sql)
  end

  def self.get_deduped_record_ids_as_bit_string(
    node_selected_value_ids_table_name, node_field_table_name, total_records, &block
  )
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.get_deduped_record_ids_sql(
            node_selected_value_ids_table_name, node_field_table_name
          )
    get_query_result_ids_as_bit_string(total_records, @@node_ds, sql) do |row|
      yield(row)
    end
  end

  def self.query_result_ids_as_bit_string(payload, db_connection, sql, &block)
    bit_string = BinaryString.build(payload.header.total_records)
    db_connection[sql].paged_each(rows_per_fetch: batch_size) do |row|
      bit_string.set_bit(row[:id]) unless row[:id].nil?
      if block_given?
        yield(row)
      end
    end
    bit_string
  end

  def self.get_query_result_ids_as_bit_string(
    total_records, db_connection, sql, &block
  )
    bit_string = BinaryString.build(total_records)
    db_connection[sql].paged_each(rows_per_fetch: batch_size) do |row|
      bit_string.set_bit(row[:id]) unless row[:id].nil?
      if block_given?
        yield(row)
      end
    end
    bit_string
  end
  #-----------------------------------------------------------------------------

  # High-cadinality Breakdowns -------------------------------------------------
  def self.node_drop_breakdown_record_ids_table(table_name)
    drop_table(
      db_connection: @@node_ds,
      table_name: table_name
    )
  end

  def self.breakdown_record_ids_by_value_id(payload)
    generator = SqlCode::Generator.new(payload: payload)
    sql = generator.breakdown_record_ids_by_value_id_sql
    
    @@node_ds[sql]
  end

  def self.insert_in_breakdown_record_ids_table_from_binary_string(
    table_name,binary_string, offset
  )
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.insert_in_breakdown_record_ids_table_from_binary_string_sql(
            table_name,offset
          )

    param = {value: binary_string, format: BINARY}

    @@node_ds.synchronize do |conn|
      conn.exec_params(sql, [param])
    end
  end
  #-----------------------------------------------------------------------------

  # Breakdown results table ----------------------------------------------------
  def self.drop_and_create_breakdown_results_table(
    payload, breakdowns, active_selects
  )
    @@central_ds.run "SET ROLE temper"

    %w[view table].each do |relation|
      name = payload.send("breakdown_results_#{relation}_name")
      send("drop_#{relation}",
        db_connection: @@central_ds,
        :"#{relation}_name" => name
      )
    end

    formatted_value_columns = []
    last_row_columns = [] # when breakdown reaches row limit
    value_columns_as_text = []

    columns = {}
    field_info = []
    zip_index = nil
    breakdowns.each.with_index do |breakdown, i|
      columns[breakdown.field_name] = :int
      payload.field = breakdown
      table_name = payload.field_values_table_name
      field_info << {
        field_name: breakdown.field_name, table_name: table_name,
        field_caption: breakdown.field_caption
      }
      formatted_value_columns << payload.breakdown_formatted_value_column
      value_columns_as_text << "CAST(\"#{breakdown.field_caption}\" AS TEXT)"

      if breakdown.field_name == 'zip5' && payload.header.has_radius?
        formatted_value_columns << "from_zip5 AS \"Centroid\""
        value_columns_as_text << "CAST(\"Centroid\" AS TEXT)"
        formatted_value_columns << "trunc(distance::numeric,1) AS \"Distance\""
        value_columns_as_text << "CAST(\"Distance\" AS TEXT)"
      end
    end

    last_row_columns = Array.new(formatted_value_columns.size - 1, "''")
    last_row_columns << "'Others'::TEXT"

    create_table(
      db_connection: @@central_ds,
      table_name: payload.breakdown_results_table_name,
      columns: columns.merge({total: :int})
    )

    generator = SqlCode::Generator.new(payload: payload)
    sql = generator.breakdown_results_view_query_sql(
            field_info,
            formatted_value_columns,
            value_columns_as_text,
            last_row_columns,
            active_selects
          )
    name = payload.breakdown_results_view_name

    create_view(db_connection: @@central_ds, view_name: name, query: sql)

    @@central_ds.run "RESET ROLE"
  end

  def self.insert_breakdown_results(payload, value_tuples)
    generator = SqlCode::Generator.new(payload: payload)

    @@central_ds.transaction do
      value_tuples.each do |value_ids|
        sql = generator.insert_breakdown_results_sql(
          value_ids.map { |v| v.nil? ? 'NULL' : v }.join(', ')
        )
        @@central_ds.run(sql)
      end
      # raise Sequel::Rollback
    end
  end
  #-----------------------------------------------------------------------------

  # Order ----------------------------------------------------------------------
  def self.create_order_record_ids_table(order_record_ids_table_name)
    create_table(
      db_connection: @@central_ds,
      table_name: order_record_ids_table_name,
      columns: {id: :int}
      )
  end

  def self.drop_order_record_ids_table(order_record_ids_table_name)
    drop_table(
      db_connection: @@central_ds,
      table_name: order_record_ids_table_name,
      )
  end

  def self.insert_order_record_ids_table(
    order_record_ids_table_name, result_bit_string
  )
    result = BinaryString.new(result_bit_string)
    generator = SqlCode::Generator.new(payload: nil)

    result.positions_by_batch(batch_size) do |positions|
      sql = generator.insert_order_record_ids_sql(
              order_record_ids_table_name, positions
            )
      @@central_ds.run sql
    end
  end

  def self.extract_order_records(
    outputs, formatted_outputs, formatted_sorts, active_selects, 
    record_key_fields, temporary_table_name, full_file_table_name,
    order_record_ids_table_name, count_values_table_name, zip5_distance_table,
    order_result_filename, header, has_pii
  )
    generator = SqlCode::Generator.new(payload: nil)

    sql = generator.extract_order_records_sql(
            outputs.join(', '), formatted_outputs.join(', '),
            formatted_sorts.join(', '), active_selects,
            record_key_fields.join(', '), temporary_table_name,
            full_file_table_name, order_record_ids_table_name,
            count_values_table_name, zip5_distance_table,
            order_result_filename, header, has_pii
          )
    binding.pry
    @@central_ds.run sql
  end

  def self.count_tracked_field_records(
    tracked_field, temporary_table_name
  )
    generator = SqlCode::Generator.new(payload: nil)

    sql = generator.count_tracked_field_records_sql(
      tracked_field, temporary_table_name
    )
    @@central_ds[sql].first![:count]
  end

  def self.create_order_keys_table(
    order_record_keys_table_name, record_key_fields, temporary_table_name
  )
    generator = SqlCode::Generator.new(payload: nil)

    sql = generator.create_order_keys_table_sql(
            order_record_keys_table_name,
            record_key_fields,
            temporary_table_name
          )

    @@central_ds.run sql
  end

  def self.drop_order_record_keys_table(order_record_keys_table_name)
    drop_table(
      db_connection: @@central_ds,
      table_name: order_record_keys_table_name,
      )
  end

  def self.drop_order_temporary_table(temporary_table_name)
    drop_table(
      db_connection: @@central_ds,
      table_name: temporary_table_name
      )
  end

  
  # Dedupe ----------------------------------------------------------------------

  def self.insert_in_dedupe_record_ids_table_from_binary_string(
    table_name, binary_string, offset
  )
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.insert_in_dedupe_record_ids_table_from_binary_string_sql(
            table_name, offset
          )
    
    param = {value: binary_string, format: BINARY}

    @@node_ds.synchronize do |conn|
      conn.exec_params(sql, [param])
    end
  end

  def self.drop_deduped_values_ids_table(table_name)
    drop_table(
      db_connection: @@node_ds,
      table_name: table_name
    )
  end

  #-----------------------------------------------------------------------------

  # Suppress -------------------------------------------------------------------

  def self.get_suppress_record_ids_as_bit_string(table_name, total_records)
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.get_suppress_record_ids_sql(table_name)
    get_query_result_ids_as_bit_string(total_records, @@central_ds, sql)
  end

  def self.get_suppress_value_ids_as_bit_string(
    count_values_table_name, count_values_column_name,
    total_records, field_values_table_name
  )
    generator = SqlCode::Generator.new(payload: nil)
    sql = generator.get_suppress_value_ids_sql(
            count_values_table_name,
            count_values_column_name,
            field_values_table_name
          )
    get_query_result_ids_as_bit_string(total_records, @@central_ds, sql)
  end

  #-----------------------------------------------------------------------------

  # Clone ----------------------------------------------------------------------

  def self.clone_count_values_table(payload, old_selects, new_selects)
    sql = SqlCode::Generator.new(payload: payload)
            .clone_count_values_table_sql(old_selects, new_selects)
    @@central_ds.run sql
  end

  # ----------------------------------------------------------------------------

  # Generic methods
  def self.drop_table(db_connection:, table_name:)
    full_table_name = "\"process\".\"#{table_name}\""
    db_connection.run("DROP TABLE IF EXISTS #{full_table_name}")
  end

  def self.drop_view(db_connection:, view_name:)
    db_connection.run("DROP VIEW IF EXISTS #{view_name}")
  end

  def self.create_table(db_connection:, table_name:, columns:)
    cols = columns.to_a.map{ |name, type| "#{name} #{type}" }.join(',')
    full_table_name = "\"process\".\"#{table_name}\""
    db_connection.run("CREATE TABLE IF NOT EXISTS #{full_table_name} (#{cols})")
  end

  def self.create_view(db_connection:, view_name:, query:)
    full_view_name = "\"process\".\"#{view_name}\""
    db_connection.run("CREATE OR REPLACE VIEW #{full_view_name} AS #{query}")
  end

  def self.save_query_result_to_file(db_connection:, query:, filename:)
    db_connection.run("COPY (#{query}) TO '#{filename}' WITH BINARY")
  end

  def self.save_table_to_file(db_connection:, table_name:, filename:)
    full_table_name = "\"process\".\"#{table_name}\""
    db_connection.run("COPY #{full_table_name} TO '#{filename}' WITH BINARY")
  end

  def self.citext_present?(db_connection:)
    sql = "select * from pg_extension where extname = 'citext'"
    db_connection[sql].count > 0
  end

  def self.table_exists?(db_connection:, table_name:)
    db_connection.table_exists?(table_name)
  end

  def self.rename_table(db_connection:, table_name:, new_table_name:)
    full_table_name = "\"process\".\"#{table_name}\""
    db_connection.run(
      "ALTER TABLE #{full_table_name} RENAME TO #{new_table_name}"
    )
  end

  # Alias
  def self.batch_size;  Configuration.numbers['batch_size']; end
end
