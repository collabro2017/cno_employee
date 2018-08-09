class Datasource < ActiveRecord::Base
  acts_as_paranoid

  has_many :counts
  has_many :concrete_fields
  has_many :fields,
    through: :concrete_fields,
    before_add: :validate_uniqueness_of_field_within_datasource

  has_many :datasource_restricted_companies
  has_many :companies, through: :datasource_restricted_companies

  has_many :datasource_restricted_users
  has_many :users, through: :datasource_restricted_users

  validates :name,
    presence: true,
    format: { with: /\A[a-z0-9_]+\z/ },
    length: { maximum: 64, too_long: "%{count} characters maximum" }

  classy_enum_attr :access_level, default: :open

  # being 'deleted' is now treated as 'outdated' (paranoia handles this state)
  alias_method :outdated?, :deleted?

  def datafile_class
    if !!self.id
      class_name = "Datafile#{self.id}"

      if Object.const_defined?(class_name)
        Object.const_get(class_name)
      else 
        klass = Class.new(DatafilesDatabase::Base)
        prefix = klass.table_name_prefix
        klass.table_name = "#{prefix}#{self.name}"
        Object.const_set class_name, klass
        klass
      end
    end
  end

  def field_categories
    FieldCategory.uniq
      .joins(:concrete_fields)
      .merge(self.concrete_fields)
      .unscope(:order)
      .order(:name)
  end

  def default_output_layout
    self.concrete_fields
      .where.not(default_output_layout: nil)
      .unscope(:order)
      .order(:default_output_layout)
  end

  private
    def validate_uniqueness_of_field_within_datasource(field)
      raise ActiveRecord::Rollback if self.fields.include? field
    end
end
