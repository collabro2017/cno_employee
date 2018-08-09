require_relative 'db_operations'
require_relative 'configuration'
require_relative 'aws_connection'

class UploadFileTask
  class << self
    def run
      load_file
    end

    private
      def load_file
        @central_ds = DatabaseConnection['central_datastore']

        payload.field.files.each do |file|
          @file = file
          @download_path = Configuration.paths['central_ds_output_path']
          @key = "#{file.user_email}/uploads/#{file.name}"
          @table_name = payload.user_file_table_name(file.id)
          @load_table_name = payload.user_file_load_table_name(file.id)

          if !DbOperations.table_exists?(
            db_connection: @central_ds, 
            table_name: @table_name
          )
            log.info "Downloading file #{@key}"
            begin
              download_file
              create_table
              load_values
            ensure
              if File.exists?(local_file)
                File.delete(local_file)
              end

              DbOperations.drop_table(
                db_connection: @central_ds, 
                table_name: @load_table_name
              )

            end
          else
            log.info "Table #{@table_name} already exists"
          end
        end
      end

      def download_file
        bucket = ENV['APP_NAME']
        s3 = AwsConnection.s3

        original_file = s3.buckets[bucket].objects[@key]

        if File.exists?(local_file)
          File.delete(local_file)
        end
        File.open(local_file, 'wb') do |file|
          original_file.read do |chunk|
            file.write(chunk)
          end
        end
      end

      def file_extension
        File.extname(@file.name)
      end

      def local_file
        @download_path + "/user_file_#{@file.id}#{file_extension}"
      end

      def create_table
        colum = {value: :integer}
        unless payload.field.ui_data_type == 'integer'
          citext = DbOperations.citext_present?(db_connection: @central_ds)
          colum = citext ? {value: :citext} : {value: :character}
        end
        DbOperations.create_table(
          db_connection: @central_ds,
          table_name: @load_table_name,
          columns: colum
        )
      end

      def load_values
        if file_extension != ".zip"
          File.readlines(local_file).each { |line| insert_values(line) }
        else
          IO.popen("unzip -p #{local_file}") do |io| 
            while (line = io.gets) do 
              insert_values(line)
            end
          end
        end

        unless DbOperations.table_exists?(
          db_connection: @central_ds, 
          table_name: @table_name
        )
          DbOperations.rename_table(
            db_connection: @central_ds, 
            table_name: @load_table_name, 
            new_table_name: @table_name
          )
        end
      end

      def insert_values(values)
        ret = false
        values = values.nil? ? [] : split_and_clean_values(values)
        unless values.empty?
          insert_sql = <<-END_SQL.strip_heredoc
            INSERT INTO "process"."#{@load_table_name}"
              ("value")
            VALUES
              #{values.map {|value| "('#{value}')"}.join(',')}
          END_SQL

          @central_ds.run(insert_sql)
        end
      end

      def split_and_clean_values(values)
        ["\t",";","\n"].each do |delimiter|
          values.gsub!(delimiter, ',')
        end
        values.split(',').map(&:strip).reject(&:empty?)
      end

      def try_to_convert_to_integer(value)
        if /\A[+-]?\d+\z/ === value
          value.to_i
        else
          raise TypeError, "#{value} cannot be converted to integer"
        end
      end


      #Aliases
      def payload;           DecoratedPayload.instance;                      end
      def log;               Configuration.logger;                           end
      
  end #class << self

end