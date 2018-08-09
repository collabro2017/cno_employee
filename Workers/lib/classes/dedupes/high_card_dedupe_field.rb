require_relative '../field'
require_relative '../job'

module Classes
  class HighCardDedupeField < Field
    include Job
    using CoreExtensions

    def initialize(dedupe_struct, header_struct, options: {})
      @simple_count_result_key = options[:simple_count_result_key]
      @header_struct = header_struct
      super(dedupe_struct)
    end

    def field_result_key
      "#{job_key_prefix}:f#{@field_struct.field_id.pad(padding)}:hcdr"
    end

    private

      def initialize_values_enumerator
        delegate_work_to_nodes
        @values = [1].each
      end

      def delegate_work_to_nodes
        delegator = ToNodesDelegator.new
        
        keys_hash = {
          "simple_count_result_key" => @simple_count_result_key,
          "result_key" => field_result_key
        }
        options = {
          header: @header_struct.to_h.merge!(keys_hash),
          dedupe: @field_struct.to_h,
          full_field_locus: full_field_locus,
          conflict_values: @field_struct.conflict_values.to_h
        }

        delegator.enqueue(klass: 'DedupeNode', options: options)

        resque_status = Resque::Plugins::Status::Hash

        conflicts_reported = delegator.sub_jobs.map do |job|
                               resque_status.get(job)['conflicts']
                             end

        process_conflicts(conflicts_reported.flatten)
      end

      def process_conflicts(conflicts)

        by_group = {}

        conflicts.each do |conflict|
          if by_group.has_key?(conflict['value_id'])
            by_group[conflict['value_id']] << conflict['id']
          else
            by_group[conflict['value_id']] = [conflict['id']]
          end
        end

        by_group.each do |key, value|
          if by_group[key].size > 1
            RedisOperations.turn_bit_off(
              field_result_key,
              by_group[key].max
            )
          end
        end
      end

      def full_field_locus
        "#{@header_struct.datasource}_f#{padded_id}"
      end
  end
end
