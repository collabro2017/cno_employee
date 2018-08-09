module Lookups
  module Custom
    class Zip5Distance < Lookups::Lookup

      default_scope { order(:from_zip5, :distance) }
      
      self.per_page = 36

      def self.value_column
      	:to_zip5
      end

      def self.filter(centroid, distance)
        exactly_matches(:from_zip5, centroid)
          .is_lesser_or_equal_to(:distance, distance)
      end

      def self.icon
        'dot-circle-o'
      end

      def display_text
        "#{formatted_zip5} (#{self.distance} miles)"
      end

      ####
      def self.first_filter_column
        :from_zip5
      end

      def self.fuzzy_filter_column
        :distance
      end

      def formatted_zip5
        concrete_field.format_value(self.to_zip5)
      end

    end
  end
end

