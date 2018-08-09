class ValuesModelBuilder
  
  attr_accessor :count_id
  
  def initialize(count_id)
    @count_id = count_id
  end
  
  def build_or_get_model
    if Object.const_defined?(class_name)
      return Object.const_get(class_name)
    else
      create_table_if_not_exists
      return define_class
    end
  end
  
  private
    def database
      @db ||= ProcessDatabase::Base
    end

    def table_name
      domain = "#{CNO::RailsApp.config.custom.domain}"
      "#{database.table_name_prefix}#{domain}_count#{@count_id}_value".tableize
    end
    
    def class_name
      table_name.classify
    end

    def create_table_if_not_exists
      conn = database.connection
      unless conn.table_exists?(table_name)
        conn.execute("SET ROLE temper")
        
        conn.create_table table_name do |t|
          t.integer :select_id, foreign_key: false
          t.integer :integer_value
          t.column  :string_value, citext_present? ? :citext : :string
          t.string  :input_method
          t.json    :lookup_params
        end
        
        conn.execute("RESET ROLE")
      end
    end

    def citext_present?
      sql = "select * from pg_extension where extname = 'citext'"
      database.connection.select_rows(sql).count > 0
    end
    
    def define_class
      klass = Class.new(database) do
        belongs_to :select
        classy_enum_attr  :input_method,
                          enum: 'InputMethodType',
                          default: 'enter_value'
        
        InputMethodType.map(&:to_sym).each do |method|
          self.define_singleton_method(method) do
            where(input_method: method)
          end
        end
        
        # TO-DO: Fix this method's efficiency and legibility
        def self.values_array 
          selects = select(:select_id).distinct.to_a
          
          db_data_types = selects.map{ |v|
            v.select.db_data_type if v.select
          }.map(&:to_s).uniq
          
          if db_data_types.size == 1 && !!db_data_types[0]
            pluck("#{db_data_types[0]}_value")
          else
            values = select("COALESCE(string_value, CAST(integer_value AS varchar(255))) AS value")
            values.to_a.map(&:value)
          end
        end
      end
      Object.const_set class_name, klass
      klass
    end
end
