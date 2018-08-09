shared_context "uses a lookup model" do
  before do
    LookupDummyBuilder.build_model
  end
  
  after do
    LookupDummyBuilder.destroy_model
  end
end

shared_context "uses a lookup table" do
  before do
    LookupDummyBuilder.build_table
  end
  
  after do
    LookupDummyBuilder.destroy_table_if_exists
  end
end

shared_context "uses a lookup class" do
  before do
    LookupDummyBuilder.build_class
  end
  
  after do
    LookupDummyBuilder.destroy_class_if_exists
  end
end

# TO-DO: Specs for this class
class LookupDummyBuilder
  DEFAULT_FIELDS = {i_value: :integer, s_value: :string, t_value: :text}
  @@table_name = "lookup_dummies"
  @@class_name = @@table_name.singularize.camelize
  @@module = Lookups
  @@class = "#{@@module.name}::#{@class_name}".constantize
  @@parent_class = Lookups::Lookup
  @@connection = @@parent_class.connection
 
  def self.build_model(fields = DEFAULT_FIELDS)         
    build_table(fields)
    build_class(fields)
  end
  
  def self.build_table(fields = DEFAULT_FIELDS)
    self.destroy_table_if_exists

    @@connection.create_table @@table_name do |t|
      fields.each do |name, type|
        t.send(type, name)
      end
    end
    
    if @@module.const_defined?(@@class_name)
      klass.column_names # this line is required in some cases for it reset
      @@class.reset_column_information
    end
  end

  def self.build_class(fields = DEFAULT_FIELDS)
     self.destroy_class_if_exists

    klass = Class.new(@@parent_class) do
      self.define_singleton_method(:first_filter_column) do
        fields.keys[0]
      end

      self.define_singleton_method(:fuzzy_filter_column) do
      	fields.keys[[1,fields.keys.size].min]
      end

      self.define_singleton_method(:value_column) do
      	fields.keys[[2,fields.keys.size].min]
      end
    end  
    @@module.const_set @@class_name, klass
    
    if @@connection.table_exists?(@@table_name)
      klass.column_names # this line is required in some cases for it reset
      klass.reset_column_information
    end
    
    klass
  end

  def self.destroy_model
    destroy_table_if_exists
    destroy_class_if_exists
  end
  
  def self.destroy_table_if_exists
    if @@connection.table_exists?(@@table_name)
      @@connection.drop_table @@table_name
    end
  end

  def self.destroy_class_if_exists
    if @@module.const_defined?(@@class_name)
      @@module.send(:remove_const, @@class_name)
    end
  end

end
