module Lookups
  class Lookup < DatafilesDatabase::Base
    @abstract_class = true

    # This will set an optional concrete field to the class
    def self.concrete_field
      @concrete_field
    end

    def self.concrete_field=(concrete_field)
      @concrete_field = concrete_field
    end

    def concrete_field
      self.class.concrete_field
    end

    def self.type
      self.name.demodulize.underscore.to_s
    end

    def self.value_column
    	raise NotImplementedError
    end

    def self.filter(*args)
      raise NotImplementedError
    end

    def self.icon
      'filter'
    end

    def display_text
      raise NotImplementedError
    end

    def self.non_blanks
      where.not(:"#{value_column}" => nil)
    end

    def self.starts_with(column, value)
      filter_if_valid(column, value) do
        where("#{column} LIKE ?", "%#{value}")
      end
    end

    def self.ends_with(column, value)
      filter_if_valid(column, value) do
        where("#{column} LIKE ?", "#{value}%")
      end
    end

    def self.fuzzy_matches(column, value)
      filter_if_valid(column, value) do
        column_sql = "#{column}"
        
        if concrete_field.db_data_type == :integer
          column_sql = "cast(#{column} as text)"
        end
        
        where("#{column_sql} LIKE ?", "%#{value}%")
      end
    end

    def self.exactly_matches(column, value)
      filter_if_valid(column, value) do
        where(:"#{column}" => value)
      end
    end

    def self.is_greater_than(column, value)
      filter_if_valid(column, value) do
        where("#{column} > ?",  value)
      end
    end

    def self.is_greater_or_equal_to(column, value)
      filter_if_valid(column, value) do
        where("#{column} >= ?",  value)
      end
    end

    def self.is_lesser_than(column, value)
      filter_if_valid(column, value) do
        where("#{column} < ?",  value)
      end
    end

    def self.is_lesser_or_equal_to(column, value)
      filter_if_valid(column, value) do
        where("#{column} <= ?", value)
      end
    end

    def self.default_order
      if concrete_field.numeric_sort
        number = "replace(substring(#{value_column} from '[0-9,]+'),',','')"
        order("cast(nullif(#{number},'') as int)")
      else
        order(value_column)
      end
    end

    def self.filter_if_valid(column, value)
      if self.column_names.include?(column.to_s) && value.present? && block_given?
        yield
      else
        all
      end
    end

  end
end
