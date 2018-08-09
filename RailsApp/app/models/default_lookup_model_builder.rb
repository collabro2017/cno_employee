class DefaultLookupModelBuilder
  
  attr_accessor :concrete_field
  
  def initialize(concrete_field)
    @concrete_field = concrete_field
  end
  
  def build_model
    if Lookups.const_defined?(class_name)
      Lookups.const_get(class_name)
    else
      define_class
    end
  end
  
  private
    def table_name
      @table_name ||= concrete_field.column_table
    end
    
    def class_name
      table_name.classify
    end

    def define_class
      klass = Class.new(Lookups::DefaultLookupBase) do
        self.primary_key = :id     

        def self.lookup_class
          self.class
        end

        def self.id
          "default_#{self.concrete_field.id}"
        end
      end

      klass.table_name = "#{table_name}_values"
      Lookups.const_set(class_name, klass)
      klass
    end
    
end
