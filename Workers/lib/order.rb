require_relative 'job'
require_relative 'redis_operations'

class Order < Job

  attr_reader   :count_result_key
  attr_accessor :count_result_bit_string, :ftp_url, :s3_url,
                :temp_table_name, :temp_pii_table_name

  def inner_run
    run_total_count

    @count_result_key = if options_struct.dedupes.empty?
                          payload.simple_count_result_key
                        else
                          payload.deduped_count_result_key
                        end

    @count_result_bit_string = RedisOperations.get_bit_string(count_result_key)

    log.info "Running order"
    run_order

    log.info "Extracting order statistics"
    statistics = extract_order_statistics

    completed(
      'ftp_url'      => @ftp_url,
      's3_url'       => @s3_url,
      'completed_at' => formatted_current_time,
      'statistics'   => statistics
    )
  end

  private

    def run_order
      create_domain_directory
      create_and_fill_record_ids_table
      extract_order_records
      if has_pii?
        extract_pii_records
        join_output_files
        sort_output_file
      end
      compress_and_send_file
      create_order_keys_table
    ensure
      cleanup
    end

    def create_domain_directory
      FileUtils.mkdir_p(File.join(central_ds_output, domain))
      FileUtils.chmod(0777, File.join(central_ds_output, domain))
    end

    def create_and_fill_record_ids_table
      DbOperations.create_order_record_ids_table(order_record_ids_table_name)
      DbOperations.insert_order_record_ids_table(
        order_record_ids_table_name, @count_result_bit_string
      )
    end

    def extract_order_records
      outputs = options_struct.outputs
      record_key_fields = has_pii? ? [] : options_struct.record_key_fields
      output_fields = (outputs.map(&:field_name) - record_key_fields)

      formatted_outputs = outputs.map do |field|
                            order_formatted_value_column(field)
                          end
      formatted_outputs << 'rnum' if has_pii?

      formatted_sorts = options_struct.sorts.map do |field|
                          formatted_order_sort(field)
                        end

      DbOperations.drop_order_temporary_table(order_temporary_table_name)
      DbOperations.extract_order_records(
        output_fields, formatted_outputs, formatted_sorts,
        options_struct.active_selects, record_key_fields,
        order_temporary_table_name, full_file_table_name,
        order_record_ids_table_name, count_values_table_name,
        zip5_distance_table, order_result_filename, payload.header, has_pii?
      )
    end

    def extract_pii_records
      ouputs = options_struct.pii_data.outputs
      record_key_fields = options_struct.pii_data.record_key
      output_fields = (ouputs - record_key_fields)

      DbOperations.drop_order_temporary_table(order_temporary_pii_table_name)
      DbOperations.extract_order_records(
        output_fields, ouputs, [], options_struct.active_selects, 
        record_key_fields, order_temporary_pii_table_name, 
        full_file_pii_table_name,order_record_ids_table_name,
        count_values_table_name, zip5_distance_table, order_pii_result_filename, 
        payload.header, has_pii?
      )
    end

    def join_output_files
      FileUtils.rm_rf(order_result_filename_temp)

      cmd = "paste -d ',' #{order_pii_result_filename} " + \
            "#{order_result_filename} >> #{order_result_filename_temp}"

      `#{cmd}`
    end

    #TO-DO: This is working, but needs to be improved
    def sort_output_file
      FileUtils.rm_rf(order_result_filename)

      cmd = "head -1 #{order_result_filename_temp} | rev | " + \
            "cut -d ',' -f 2- | rev > #{order_result_filename}"

      `#{cmd}`

      cmd = "tail -n +2 #{order_result_filename_temp} | " + \
            "awk -F ',' -v OFS=',' '{print $NF,$0}' | " + \
            "sort -t ',' -k1,1 -n | cut -d ',' -f 2- | " + \
            "rev | cut -d ',' -f 2- | rev >> #{order_result_filename}"

      `#{cmd}`

      FileUtils.rm_rf(order_result_filename_temp)
    end

    def has_pii?
      !options_struct.pii_data.to_h.empty?
    end

    def compress_and_send_file
      `zip -j #{order_zipped_result_filename} #{order_result_filename}`

      @s3_url = upload_to_s3
      @ftp_url = upload_to_ftp
    end

    def create_order_keys_table
      if has_pii?
        record_key = options_struct.pii_data.record_key
        temporary_table_name = temp_pii_table_name
      else
        record_key = options_struct.record_key_fields
        temporary_table_name = temp_table_name
      end

      DbOperations.drop_order_record_keys_table(order_record_keys_table_name)
      DbOperations.create_order_keys_table(
        order_record_keys_table_name, record_key, temporary_table_name
      )
    end

    def cleanup
      FileUtils.rm_rf(order_result_filename)
      FileUtils.rm_rf(order_pii_result_filename)
      FileUtils.rm_rf(order_zipped_result_filename)
      DbOperations.drop_order_record_ids_table(order_record_ids_table_name)
    end

    def upload_to_ftp
      FileTransfer.upload_to_ftp(
        filename: order_zipped_result_filename,
        user_email: payload.header.user_email,
        ftp_server: options_struct.ftp_server
      )
    end

    def upload_to_s3
      FileTransfer.upload_to_s3(
        bucket: "rb-#{domain}",
        filename: order_zipped_result_filename,
        user_email: payload.header.user_email
      )
    end

    def extract_order_statistics
      statistics = {}
      options_struct.outputs.each do |field|
        if field.tracked?
          total = DbOperations.count_tracked_field_records(
            field.field_name, order_temporary_table_name
          )
          statistics[field.field_id] = total
        end
      end
      statistics
    ensure
      DbOperations.drop_order_temporary_table(order_temporary_table_name)
      DbOperations.drop_order_temporary_table(order_temporary_pii_table_name)
    end

    # Tables and filenames ---------------------------

    def order_record_ids_table_name
      "#{domain}_#{order_base_info}_record_ids"
    end

    def order_temporary_table_name
      return @temp_table_name if defined?(@temp_table_name)
      
      @temp_table_name = "#{domain}_#{order_base_info}_#{SecureRandom.uuid}"
    end

    def order_temporary_pii_table_name
      return @temp_pii_table_name if defined?(@temp_pii_table_name)
      
      @temp_pii_table_name = "#{domain}_#{order_base_info}_#{SecureRandom.uuid}"
    end

    def order_record_keys_table_name
      "#{domain}_#{order_base_info}_record_keys"
    end

    def order_result_filename_temp
      File.join(central_ds_output, domain, "#{order_base_info}.csv.temp")
    end

    def order_result_filename
      File.join(central_ds_output, domain, "#{order_base_info}.csv")
    end

    def order_pii_result_filename
      File.join(central_ds_output, domain, "#{order_base_info}_pii.csv")
    end

    def order_zipped_result_filename
      File.join(central_ds_output, domain, "#{order_base_info}.zip")
    end

    def order_base_info
     "order#{payload.header.order_id}"
    end

    def full_file_table_name
      "#{payload.header.datasource}_full"
    end

    def full_file_pii_table_name
      "#{options_struct.pii_data.datasource}_full"
    end

    def count_values_table_name
      "#{domain}_count#{payload.header.count_id}_values"
    end

    def zip5_distance_table
      "zip5_distances"
    end

    def order_formatted_value_column(field)
      if field.special && payload.header.has_radius?
        'from_zip5 as centroid, trunc(distance::numeric,1) as distance'
      else
        field_name = field.field_name
        format = field.pg_format
        data_type = field.db_data_type

        if format.nil? || format.empty? || (data_type != 'integer')
          field_name
        else
          "TO_CHAR(\"#{field_name}\", '#{format}') as #{field_name}"
        end
      end
    end

    def formatted_order_sort(field)
      direction = ' DESC' if field.descending?

      if field.special && payload.header.has_radius?
        "from_zip5#{direction}, distance#{direction}"
      else
        "#{field.field_name}#{direction}"
      end
    end

    #Alias
    def domain;            payload.header.domain;                            end
    def log;               Configuration.logger;                             end
    def central_ds_output; Configuration.paths['central_ds_output_path'];    end

end
