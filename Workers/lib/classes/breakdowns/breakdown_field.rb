module Classes
  module BreakdownField

    NAMESPACE = 'sway'.freeze
    PBDR_KEY_SUFFIX = '):pbdr'.freeze

    def self.extract_value_ids_from_pbdr_key(key)
      values = key.scan(/_v\d+/)
      values.map { |s| s.sub('_v', '').to_i } unless values.empty?
    end

    def reset_filter_key(new_filter_key)
      @filter_key = new_filter_key
      @values.each { |value_id| RedisOperations.del(pbdr_key_for(value_id)) }
      initialize_values_enumerator
    end

    def current_pbdr_key
      pbdr_key_for(@current_value_id) if @current_value_id
    end

    def current_pbdr_row
      if (key = current_pbdr_key)
        [
          *BreakdownField::extract_value_ids_from_pbdr_key(key),
          RedisOperations.bitcount(key)
        ]
      end
    end

    private
      def pbdr_key_for(value_id)
        raise(ArgumentError, 'Cannot find pbdr key for nil') unless value_id

        escaped_suffix = Regexp.escape(PBDR_KEY_SUFFIX)

        if(match_data = @filter_key.match(/\A(.+\()(.*)#{escaped_suffix}\z/))
          prefix, pairs = match_data.captures
          "#{prefix}#{pairs}-#{value_locus_for(value_id)}#{PBDR_KEY_SUFFIX}"
        else
          prefix = "#{NAMESPACE}:#{@header_struct.domain}:j#{job_id}:("
          "#{prefix}#{value_locus_for(value_id)}#{PBDR_KEY_SUFFIX}"
        end
      end

      def job_id
        @header_struct.job_id
      end
  end
end

