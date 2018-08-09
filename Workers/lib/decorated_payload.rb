require 'singleton'
require_relative 'configuration'
require_relative 'extensions/core_extensions'

class DecoratedPayload

  include Singleton
  using CoreExtensions

  APP_KEY_PREFIX = "sway".freeze
  
  [:header, :field, :value_id, :node_id].each do |attribute|
    attr_accessor attribute

    define_method("with_tmp_#{attribute}") do |tmp_value, &block|
      backup = send(attribute)
      backup = begin backup.dup; rescue TypeError; backup end
      send("#{attribute}=", tmp_value)
      ret = block.call
      send("#{attribute}=", backup)
      ret
    end

    method = define_method("safe_#{attribute}") do
      value = self.send(attribute)
      if value.nil?
        raise "there isn't a #{attribute} assigned to the payload yet" 
      else
        value
      end
    end
    private method
  end

  # Redis keys -----------------------------------------------------------------
  def simple_count_result_key
    "#{job_key_prefix}:scr"
  end

  def deduped_count_result_key
    "#{job_key_prefix}:dcr"
  end

  def linked_count_result_key
    "#{job_key_prefix}:lcr"
  end

  def low_cardinality_field_bit_string_key
    "#{APP_KEY_PREFIX}:#{full_field_value_locus}:lcfbs"
  end

  # Bit string filenames -------------------------------------------------------
  def low_cardinality_field_bit_string_filename
    File.join(bit_strings_dir, "#{full_field_value_locus}.bin")
  end

  # Table names ----------------------------------------------------------------
  def full_file_table_name
    "#{header.datasource}_full"
  end

  def field_values_table_name
    "#{full_field_locus}_values"
  end

  def count_values_table_name
    "#{domain}_count#{header.count_id}_values"
  end

  def count_values_column_name
    "#{safe_field.db_data_type}_value"
  end

  def node_field_table_name
    "#{full_field_locus}_n#{safe_node_id.pad(padding)}"
  end

  def node_selected_value_ids_table_name
    "#{field_locus_in_job}_n#{safe_node_id.pad(padding)}"
  end

  def node_breakdown_record_ids_table_name
    "#{field_locus_in_job}_bd_record_ids_n#{safe_node_id.pad(padding)}"
  end

  def breakdown_results_view_name
    "#{domain}_count#{header.count_id}_breakdown_results"
  end

  def breakdown_results_table_name
    "#{domain}_#{breakdown_results_view_name}_table"
  end

  def user_file_table_name(file_id)
    "user_file_#{file_id}"
  end

  def user_file_load_table_name(file_id)
    "user_file_#{file_id}_#{SecureRandom.uuid}"
  end

  def user_file_values_column_name
    "value"
  end

  def zip5_distance_table
    "zip5_distances"
  end

  # Formatted value column -----------------------------------------------------

  def breakdown_formatted_value_column
    table_name = "\"#{field_values_table_name}\".\"value\""
    field_caption = safe_field.field_caption
    format = safe_field.pg_format
    data_type = safe_field.db_data_type

    if format.empty? || (data_type != 'integer')
      "#{table_name} AS \"#{field_caption}\""
    else
      "TO_CHAR(#{table_name} , '#{format}') AS \"#{field_caption}\""
    end
  end

  private
    def job_key_prefix
      "#{APP_KEY_PREFIX}:#{domain}:j#{safe_header.job_id}"
    end

    def full_field_locus
      "#{header.datasource}_f#{safe_field.field_id.pad(padding)}"
    end

    def full_field_value_locus
      "#{full_field_locus}_v#{safe_value_id.pad(padding)}"
    end

    def field_locus_in_job
      "#{domain}_j#{safe_header.job_id}_f#{safe_field.field_id.pad(padding)}"
    end

    # Aliases ------------------------------------------------------------------
    def domain;            safe_header.domain;                               end

    # Numbers
    def padding;           Configuration.numbers['padding'];                 end

    # Paths
    def bit_strings_dir;   Configuration.paths['bit_strings_dir'];           end
    def central_ds_output; Configuration.paths['central_ds_output_path'];    end
    def node_ds_input;     Configuration.paths['node_ds_input_path'];        end

end
