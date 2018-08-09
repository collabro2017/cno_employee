module Lookups
  class DefaultLookupBase < Lookups::Lookup
 
    @abstract_class = true

    def self.type
      "default_lookup"
    end

    def self.value_column
    	:value
    end

    def self.filter(first, fuzzy)
      self.fuzzy_matches(self.value_column, fuzzy)
    end

    def self.icon
      'check-square-o'
    end

    def display_text
      concrete_field.format_value(value)
    end

    ####
    def self.first_filter_column
      :value
    end

    def self.fuzzy_filter_column
      :value
    end

  end
end
