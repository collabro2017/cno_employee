class ConcreteFieldInputMethod < ActiveRecord::Base
  belongs_to :concrete_field
  validates_presence_of :concrete_field
  validates_presence_of :input_method_type

  before_save :validate_concrete_field

  classy_enum_attr :input_method_type
  
  include Sortable
  self.scope_attribute = :concrete_field

  def self.enabled
    where(enabled: true)
  end

  def self.lookup_class(lookup_type, concrete_field: nil)
    const = nil

    input_method = InputMethodType.find(lookup_type)
    if input_method.is_default_lookup? && concrete_field.present?
      const = concrete_field.default_lookup_class
    else
      class_name = input_method.lookup_class_name

      begin
        const = class_name.constantize
      rescue NameError ; end
    end

    if const.is_a?(Class)
      const.concrete_field = concrete_field if concrete_field.present?
    end

    const
  end

  def lookup_class
    self.class.lookup_class(read_attribute(:input_method_type))
  end

  private
    def validate_concrete_field
      case self.input_method_type.to_s
      when 'binary'
        unless self.concrete_field.ui_data_type == :binary
          raise StandardError, 'invalid, concrete field ui_data_type not binary'
        end
      when 'number_range'
        unless self.concrete_field.ui_data_type == :integer
          raise StandardError,'invalid, concrete field ui_data_type not integer'
        end
      when 'date_range'
        unless self.concrete_field.ui_data_type == :date
          raise StandardError, 'invalid, concrete field ui_data_type not date'
        end
      end
    end
end
