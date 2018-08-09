module Lookups
  module Custom
    class Zip5 < Lookups::Lookup

      default_scope { order(:state, :city, :zip5) }
      
      self.per_page = 36

      def self.value_column
        :zip5
      end

      def self.filter(state, city)
        exactly_matches(:state, state).fuzzy_matches(:city, city)
      end

      def display_text
        "#{self.state_code} - #{self.city || "(blank)"} - #{formatted_zip5}"
      end

      ####
      def self.first_filter_column
        :state
      end

      def self.fuzzy_filter_column
        :city
      end

      def formatted_zip5
        concrete_field.format_value(zip5)
      end

    end
  end
end

