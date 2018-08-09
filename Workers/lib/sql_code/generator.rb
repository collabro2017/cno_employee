require_relative 'renderer'

module SqlCode
  class Generator

    attr_reader :payload

    def initialize(payload:)
      @payload = payload
    end

    def get_selected_value_ids_sql(
      select_struct, field_values_table_name, criteria
    )
      return @get_selected_value_ids_sql if defined?(@get_selected_value_ids_sql)

      queries = criteria.map do |criterion|
                  self.send(
                    "#{criterion}_value_ids_sql",
                    select_struct,
                    field_values_table_name
                  )
                end

      @all_value_ids_sql = queries.any? ? queries.join("\nUNION\n") : nil
      @all_value_ids_sql << "\nORDER BY \"id\"" unless @all_value_ids_sql.nil?

    end

    def values_value_ids_sql(select_struct, field_values_table_name)
      condition = {
        name:                     :values,
        count_values_table_name:  select_struct.count_values_table_name,
        count_values_column_name: select_struct.count_values_column_name,
        select_id:                select_struct.select_id
      }
      value_ids_sql(
        condition: condition, field_values_table_name: field_values_table_name
      )
    end

    def ranges_value_ids_sql(
      select_struct, field_values_table_name
    )
      condition = {
        name: :ranges,
        from: select_struct.range_from,
        to: select_struct.range_to
      }
      
      value_ids_sql(
        condition: condition, field_values_table_name: field_values_table_name
      )
    end

    def blanks_criterion_value_ids_sql(
      select_struct, field_values_table_name
    )
      condition = {name: :blanks_criterion, blanks?: select_struct.blanks}
      value_ids_sql(
        condition: condition, field_values_table_name: field_values_table_name
      )
    end

    def files_value_ids_sql(select_struct, field_values_table_name)
      queries = []
      select_struct.files.each do |file|
        condition = {
          name:                     :values,
          count_values_table_name:  payload.user_file_table_name(file.id),
          count_values_column_name: payload.user_file_values_column_name
        }
        queries << value_ids_sql(
                    condition: condition, 
                    field_values_table_name: field_values_table_name
                  )
      end
      queries.any? ? queries.join("\nUNION\n") : nil
    end

    def value_ids_sql(condition: nil, field_values_table_name:)
      values = {
        field_values_table_name: field_values_table_name,
        condition: condition
      }
      Renderer.new(template_name: :value_ids, values: values).result
    end

    def insert_in_selected_value_ids_table_from_binary_string_sql(
      table_name, offset
    )
      values = { 
        table_name: table_name, 
        offset: offset
      }

      Renderer.new(
        template_name: :insert_in_dedupe_record_ids_table_from_binary_string,
        values: values
      ).result
    end

    def selected_record_ids_sql
      values = {
        node_selected_value_ids_table_name:
          payload.node_selected_value_ids_table_name,
        node_field_table_name:
          payload.node_field_table_name
      }
      Renderer.new(template_name: :selected_record_ids, values: values).result
    end

    def get_selected_record_ids_sql(
      node_selected_value_ids_table_name, node_field_table_name
    )
      values = {
        node_selected_value_ids_table_name: node_selected_value_ids_table_name,
        node_field_table_name: node_field_table_name
      }
      Renderer.new(template_name: :selected_record_ids, values: values).result
    end

    def breakdown_record_ids_by_value_id_sql
      values = {
        node_breakdown_record_ids_table_name:
          payload.node_breakdown_record_ids_table_name,
        node_field_table_name:
          payload.node_field_table_name
      }
      Renderer.new(
        template_name: :breakdown_record_ids_by_value_id,
        values: values
      ).result
    end

    def insert_breakdown_results_sql(value_ids)
      values = {
        breakdown_results_table_name: payload.breakdown_results_table_name,
        value_ids: value_ids
      }

      Renderer.new(
        template_name: :insert_breakdown_results,
        values: values
      ).result
    end

    def breakdown_results_view_query_sql(
      field_info,
      formatted_value_columns, value_columns_as_text, last_row_columns,
      active_selects
    )
      values = {
        formatted_value_columns: formatted_value_columns.join(', '),
        last_row_columns: last_row_columns.join(', '),
        value_columns_as_text:      value_columns_as_text.join(', '),
        breakdown_results_table_name: payload.breakdown_results_table_name,
        field_info: field_info,
        has_radius?: payload.header.has_radius?,
        count_values_table:  payload.count_values_table_name,
        zip5_distance_table: payload.zip5_distance_table,
        active_selects: active_selects
      }

      Renderer.new(
        template_name: :breakdown_results_view_query,
        values: values
      ).result
    end

    def insert_in_breakdown_record_ids_table_from_binary_string_sql(
      table_name, offset
    )
      values = {
        table_name: table_name,
        offset: offset
      }

      Renderer.new(
        template_name: :insert_in_dedupe_record_ids_table_from_binary_string,
        values: values
      ).result
    end

    def insert_order_record_ids_sql(order_record_ids_table_name, record_ids)
      values = {
        table_name: order_record_ids_table_name,
        ids: record_ids.map { |pos| "((#{pos}))" }.join(',')
      }
      Renderer.new(template_name: :insert_ids, values: values).result
    end

    def extract_order_records_sql(
      outputs, formatted_outputs, formatted_sorts, active_selects, 
      record_key_fields, temporary_table_name, full_file_table_name,
      order_record_ids_table_name, count_values_table_name, zip5_distance_table,
      order_result_filename, header, has_pii
    )
      values = {
        outputs: outputs,
        formatted_outputs: formatted_outputs,
        formatted_sorts: formatted_sorts,
        full_file_table: full_file_table_name,
        order_table: order_record_ids_table_name,
        count_values_table:  count_values_table_name,
        zip5_distance_table: zip5_distance_table,
        total_cap: header.total_cap,
        has_radius?: header.has_radius?,
        filename: order_result_filename,
        active_selects: active_selects,
        record_key_fields: record_key_fields,
        temporary_table_name: temporary_table_name,
        has_pii?: has_pii
      }

      Renderer.new(template_name: :extract_order_records, values: values).result
    end

    def count_tracked_field_records_sql(tracked_field, temporary_table_name)
      values = {
        temporary_table_name: temporary_table_name,
        tracked_field: tracked_field
      }

      Renderer.new(
        template_name: :count_tracked_field_records, values: values
      ).result
    end

    def create_order_keys_table_sql(
      order_record_keys_table_name, record_key_fields, temporary_table_name
    )
      values = {
        record_key_fields: record_key_fields.join(', '),
        temporary_table_name: temporary_table_name,
        order_record_keys_table: order_record_keys_table_name
      }

      Renderer.new(
        template_name: :create_order_keys_table, values: values
      ).result
    end

    def get_deduped_record_ids_sql(
      node_dedupe_record_ids_table_name, node_field_table_name
    )
      values = {
        node_dedupe_record_ids_table_name: node_dedupe_record_ids_table_name,
        node_field_table_name: node_field_table_name
      }

      Renderer.new(
        template_name: :deduped_record_ids,
        values: values
      ).result
    end

    def insert_in_dedupe_record_ids_table_from_binary_string_sql(table_name, offset)
      values = { 
        table_name: table_name,
        offset: offset
      }

      Renderer.new(
        template_name: :insert_in_dedupe_record_ids_table_from_binary_string,
        values: values
      ).result
    end   

    def get_suppress_record_ids_sql(table_name)
      values = { table_name: table_name }
      Renderer.new(template_name: :order_record_ids, values: values).result
    end

    def get_suppress_value_ids_sql(
      count_values_table_name, count_values_column_name, field_values_table_name
    )
      condition = {
        name:                     :values,
        count_values_table_name:  count_values_table_name,
        count_values_column_name: count_values_column_name
      }
      value_ids_sql(
        condition: condition, field_values_table_name: field_values_table_name
      )
    end

    def clone_count_values_table_sql(old_selects, new_selects)
      values = {
        domain:       payload.header.domain,
        old_count_id: payload.header.old_count_id,
        new_count_id: payload.header.new_count_id,
        old_selects:  old_selects,
        new_selects:  new_selects
      }

      Renderer.new(
        template_name: :clone_count_values_table,
        values: values
      ).result
    end    

  end
end
