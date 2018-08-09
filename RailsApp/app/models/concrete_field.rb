require 'field_caption'

class ConcreteField < ActiveRecord::Base

  DEFAULT_PADDING = 3
  MIN_VALID_DATE = 1900_01_01

  belongs_to :datasource, -> { with_deleted }
  belongs_to :field
  belongs_to :field_category
  has_many :concrete_field_input_methods

  has_many :counts_user_files

  validates_presence_of :field
  validates_uniqueness_of :default_output_layout,
    scope: :datasource_id,
    allow_nil: true

  classy_enum_attr :db_data_type, default: :string
  classy_enum_attr :ui_data_type, allow_nil: true

  delegate :can_link?, to: :ui_data_type

  include Sortable
  self.scope_attribute = :datasource

  after_initialize :set_defaults
  before_save :set_defaults

  def self.eager_load_fields
    fields_table = Field.quoted_table_name
    name_column = self.connection.quote_column_name('name')
    description_column = self.connection.quote_column_name('description')
    
    joins(:field)
      .select("#{self.quoted_table_name}.*,\
          #{fields_table}.#{name_column} as field_name,\
          #{fields_table}.#{description_column}")
  end

  def self.with_source_fields
    where.not(source_fields: [nil, "{}"])
  end

  def name
    read_attribute(:name) || read_attribute('field_name') || field.name
  end

  def caption
    read_attribute(:caption) || FieldCaption.generate(self.name)
  end

  def description
    # Necessary because read_attribute('description') may be blank
    if has_attribute?('description')  
      read_attribute('description')
    else
      field.description
    end
  end

  def column_table
    field_id = self.position.to_s.rjust(DEFAULT_PADDING, '0') 
    table_prefix = self.datasource.datafile_class.table_name
    "#{table_prefix}_f#{field_id}"
  end

  def default_lookup_class
    @default_lookup_class ||= DefaultLookupModelBuilder.new(self).build_model
  end

  [:binary_on_value, :binary_off_value].each do |method|
    define_method(method) do
      if instance_variable_defined?("@#{method}")
        instance_variable_get("@#{method}")
      else
        if self.ui_data_type == 'binary'
          instance_variable_set("@#{method}", self.send("unsafe_#{method}"))
        else
          raise NoMethodError.new("undefined method `#{method}' for " + \
            "#<#{self.class} ui_data_type: #{ui_data_type} ... >")
        end
      end
    end
  end

  def format_value(value)
    if value.nil?
      '(Blank)'
    elsif printf_format.present?
      "#{printf_format % value}"
    else
      value
    end
  end

  def valid_min
    self.ui_data_type == 'date' ? min_valid_date : self.min
  end

  def valid_max
    self.ui_data_type == 'date' ? max_valid_date : self.max
  end

  def input_methods
    concrete_field_input_methods.enabled.order(:position)
  end

  def flags_match?(selected_concrete_field)
    self.select_enabled == selected_concrete_field.select_enabled ||
    self.breakdown_enabled == selected_concrete_field.breakdown_enabled ||
    self.dedupe_enabled == selected_concrete_field.dedupe_enabled
  end

  private
    def set_defaults
      if (self.has_attribute? :field_category_id) && self.field_category_id.nil?
        self.field_category = FieldCategory.default
      end
    end

    def min_valid_date
      reset_to_first_day_of_year([self.min, MIN_VALID_DATE].max)
    end

    def max_valid_date
      [self.max , Time.now.strftime('%Y%m%d').to_i].min
    end

    def reset_to_first_day_of_year(num)
      (num/10_000).floor * 10_000 + 101
    end

    # These unsafe methods should always be accessed through a wrapper
    def unsafe_binary_on_value
      self.default_lookup_class.last.value
    end  

    def unsafe_binary_off_value
      self.default_lookup_class.first.value
    end

end
