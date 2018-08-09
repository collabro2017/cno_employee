module Jobs
  class Breakdown < Job

    def payload
      base_payload.merge!(breakdowns: breakdowns_data)
      base_payload.merge!(active_selects: active_selects)
      base_payload[:header][:max_rows] = 
        CNO::RailsApp.config.custom.breakdown_limit
      base_payload
    end

    def results_class
      BreakdownResultsModelBuilder.new(self).build_model
    end

    def save_result_values
      super
    end

    private
      def breakdowns_data
        count.breakdowns.map do |breakdown|
          field_id = breakdown.concrete_field.position
          format = breakdown.concrete_field.pg_format.to_s
          selects = base_payload[:selects].map{ |select| select[:field_id] }
          field_caption = breakdown.concrete_field.caption

          {
            breakdown_id:    breakdown.id,
            field_id:        field_id,
            field_name:      breakdown.name,
            field_caption:   field_caption,
            pg_format:       format,
            ui_data_type:    breakdown.ui_data_type.to_s,
            db_data_type:    breakdown.db_data_type.to_s,
            is_also_select?: selects.include?(field_id),
            distinct_count:  breakdown.default_lookup_class.count,
            conflict_values: breakdown.concrete_field.conflict_values
          }
        end
      end

      def active_selects
        count.selects.active.map { |sel| { select_id: sel.id } }
      end

  end
end
