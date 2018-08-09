require_relative '../../hasher.rb'

module Classes
  class FileSuppress < Suppress
    using CoreExtensions

    def initialize(suppress_struct, header_struct)
      @header_struct = header_struct
      @suppress_struct = suppress_struct
      @central_ds = DatabaseConnection['central_datastore']
    end

    def generate_and_set_suppression_key
      #Preparation
      prepare_file
      prepare_tables
      load_file_as_keys
      rename_table

      #Process
      get_selected_value_ids
      delegate_work_to_nodes

      #Cleanup
      cleanup
    end

    private   
      def prepare_file
        @header = FileTransfer.get_header_from_s3(
                    domain:     @header_struct.domain,
                    file_id:    @suppress_struct.id,
                    user_email: @suppress_struct.user_email,
                    file_name:  @suppress_struct.name
                  )

        @positions = columns_positions(
                       @suppress_struct.criteria[:source_fields],
                       @header
                     )

        @local_file = FileTransfer.download_from_s3(
                        domain:     @header_struct.domain,
                        file_id:    @suppress_struct.id,
                        user_email: @suppress_struct.user_email,
                        file_name:  @suppress_struct.name
                      )
      end

      def prepare_tables
        DbOperations.drop_table(
          db_connection: @central_ds, 
          table_name:    suppress_table_name
        )

        DbOperations.drop_table(
          db_connection: @central_ds, 
          table_name:    suppress_file_load_table_name
        )

        DbOperations.create_table(
          db_connection: @central_ds,
          table_name:    suppress_file_load_table_name,
          columns:      {"#{@suppress_struct.criteria[:field_name]}" => :bigint}
        )
      end

      def load_file_as_keys
        if file_extension != ".zip"
          File.readlines(@local_file).each_with_index do |line, index|
            unless index == 0
              generate_and_insert_key(line)
            end
          end
        else
          io = IO.popen("unzip -p #{@local_file} | tail -n +2")
          while(line = io.gets)
            generate_and_insert_key(line)
          end
        end
      end

      def generate_and_insert_key(line)
        splitted_line = line.split(',')

        ret = {}
        @positions.each do |key,value|
          ret[key] = "#{splitted_line[value.to_i]}"
        end
        value = RB::Hasher.generate(ret)

        unless value.nil?
          insert_sql = <<-END_SQL.strip_heredoc
            INSERT INTO "process"."#{suppress_file_load_table_name}"
              ("#{@suppress_struct.criteria[:field_name]}")
            VALUES
              (#{value})
          END_SQL

          @central_ds.run(insert_sql)
        end
      end

      def columns_positions(source_fields, header)
        positions = {}
        header_hash = Hash[header.map(&:upcase).map.with_index.to_a]
        source_fields.each do |source_field|
          position = header_hash[source_field.upcase]

          if !position.nil?
            positions[source_field] = position
          else
            raise "#{source_field} not found in layout"
          end
        end
        positions
      end

      def file_extension
        File.extname(@suppress_struct.name)
      end

      def rename_table
        unless DbOperations.table_exists?(
          db_connection: @central_ds, 
          table_name:    suppress_table_name
        )
          DbOperations.rename_table(
            db_connection:  @central_ds,
            table_name:     suppress_file_load_table_name,
            new_table_name: suppress_table_name
          )
        end
      end

      def suppress_base_info
       "#{@header_struct.domain}_suppress_file#{@suppress_struct.id}"
      end

      def suppress_table_name
        "#{suppress_base_info}"
      end

      def suppress_file_load_table_name
        if !defined?(@suppress_file_load_table_name)
          name = "#{suppress_base_info}_#{SecureRandom.uuid}"
          @suppress_file_load_table_name = name
        end

        @suppress_file_load_table_name
      end

      def central_suppress_value_ids_bit_string_key
        "#{suppress_base_info}_value_ids_bit_string"
      end

      def cleanup
        if File.exists?(@local_file)
          File.delete(@local_file)
        end

        DbOperations.drop_table(
          db_connection: @central_ds, 
          table_name:    suppress_file_load_table_name
        )

        DbOperations.drop_table(
          db_connection: @central_ds, 
          table_name:    suppress_table_name
        )
      end

      # Aliases ----------------------------------------------------------------
      def total_nodes;       Configuration.numbers['total_nodes'];           end
      def padding;           Configuration.numbers['padding'];               end
      def log;               Configuration.logger;                           end
  end
end
