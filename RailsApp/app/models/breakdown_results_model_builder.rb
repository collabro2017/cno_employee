class BreakdownResultsModelBuilder

  attr_accessor :job
  
  def initialize(job)
    @job = job
  end
  
  def build_model
    if Object.const_defined?(class_name)
      model = Object.const_get(class_name)
      model.tap(&:reset_column_information).tap(&:reset_sequence_name)
    else
      define_class
    end
  end
  
  private
    def database
      @db ||= ProcessDatabase::Base
    end

    def table_name
      domain = CNO::RailsApp.config.custom.domain
      prefix = database.table_name_prefix
      "#{prefix}#{domain}_count#{@job.count.id}_breakdown_result".tableize
    end
    
    def class_name
      table_name.classify
    end

    def define_class
      klass = Class.new(database) do
        self.primary_key = :id
      end

      klass.table_name = table_name
      Object.const_set(class_name, klass)
      klass
    end
    
end