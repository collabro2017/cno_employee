require 'erb'
require 'yaml'

module Jobs
  class Order < Job

    def payload
      order_info = {
        header: {
          order_id: order_id,
          user_email: count.user.email,
          total_cap: order.total_cap
        }
      }

      base_payload.deep_merge!(order_info)
      base_payload.merge!(outputs: outputs_data)
      base_payload.merge!(sorts: sorts_data)
      base_payload.merge!(record_key_fields: record_keys_data)
      base_payload.merge!(active_selects: active_selects)
      base_payload.merge!(ftp_server: ftp_data)
      base_payload.merge(pii_data: pii_data)
    end

    def save_result_values
      self.order.ftp_url = resque_status['ftp_url']
      self.order.s3_url = resque_status['s3_url']
      self.order.count.locked = true
      self.order.count.save
      self.order.save

      statistics = resque_status['statistics']
      statistics.each do |concrete_field_id, count|
        concrete_field = ::ConcreteField.find_by(id: concrete_field_id)
        statistic = ::OrderStatistic.new(
                      job: self,
                      concrete_field: concrete_field,
                      populated_count: count
                    )
        statistic.save
      end

      save
    end

    private
      def outputs_data
        unique_outputs = order.outputs.to_a.uniq {|out| out.concrete_field_id }

        unique_outputs.map do |output|
          if output.concrete_field.nil?
            field_id = nil
            field_name= nil
            format = nil
            db_data_type = nil
            special = true
            tracked = false
          else
            field_id = output.concrete_field.id
            format = output.concrete_field.pg_format.to_s
            db_data_type = output.concrete_field.db_data_type.to_s
            field_name = output.name
            special = false
            tracked = output.concrete_field.tracked
          end

          {
            output_id:    output.id,
            position:     output.position,
            field_id:     field_id,
            field_name:   field_name,
            pg_format:    format,
            db_data_type: db_data_type,
            special:      special,
            tracked?:     tracked
          }
        end
      end

      def sorts_data
        unique_sorts = order.sorts.to_a.uniq {|sort| sort.concrete_field_id }

        unique_sorts.map do |sort|
          if sort.concrete_field.nil?
            field_name = nil
            special = true
          else
            field_name = sort.name
            special = false
          end

          {
            sort_id:       sort.id,
            position:      sort.position,
            field_name:    field_name,
            descending?:   sort.descending,
            special:       special
          }
        end
      end

      def record_keys_data
        order.datasource.concrete_fields.where(record_key: true).map do |cf|
          cf.field.name
        end
      end

      def ftp_data
        ftp_config = CNO::RailsApp.config.custom.ftp_config
        
        data = {
          in_local_network: ftp_config.in_local_network,
          private_address: ftp_config.private_address,
          public_address: ftp_config.public_address,
          username: ftp_config.username,
          password: ftp_config.password,
          folder: ftp_config.folder,
          protocol: ftp_config.protocol
        }

        data
      end

      def pii_data
        if order.datasource.pii_datasource_id
          ds = Datasource.with_deleted.find(order.datasource.pii_datasource_id)
          outputs = ds.concrete_fields.where(output: true).map do |cf|
                      cf.field.name
                    end
          record_key = ds.concrete_fields.where(record_key: true).map do |cf|
                          cf.field.name
                        end
          { datasource: ds.name, outputs: outputs, record_key: record_key }
        else
          {}
        end
      end

      def active_selects
        order.count.selects.active.map { |sel| { select_id: sel.id } }
      end

  end
end
