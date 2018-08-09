module JSONWrapper
  class JSONDatatypeWrapper < RecursiveOpenStruct

    def initialize(hash, record: nil, column_name: nil, force_save: false)
      @record, @column_name, @force_save = record, column_name, force_save
      super(
        hash,
        recurse_over_arrays: true,
        mutate_input_hash: true
      )
    end

    def new_ostruct_member(name)
      unless self.respond_to?(name)
        class << self; self; end.class_eval do
          define_method(name) do
            v = @table[name]
            if v.is_a?(Hash)
              @sub_elements[name] ||= self.class.new(
                                        v,
                                        record: @record,
                                        column_name: @column_name,
                                        force_save: @force_save
                                      )
            elsif v.is_a?(Array) and @recurse_over_arrays
              @sub_elements[name] ||= recurse_over_array(v)
            else
              v
            end
          end
          define_method("#{name}=") do |x|
            @record.send("#{@column_name}_will_change!") # Required before AR 4.2
            modifiable[name] = x
            @sub_elements.delete(name)
            @record.save if @force_save
          end
          define_method("#{name}_as_a_hash") { @table[name] }
        end
      end
      name
    end

    def recurse_over_array(array)
      array.map do |a|
        if a.is_a? Hash
          self.class.new(
            a,
            record: @record,
            column_name: @column_name,
            force_save: @force_save
          )
        elsif a.is_a? Array
          recurse_over_array a
        else
          a
        end
      end
    end

  end
end
