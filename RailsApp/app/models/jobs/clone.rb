module Jobs
  class Clone < Job

    def payload
      payload = {
        header: {
          domain:       CNO::RailsApp.config.custom.domain.downcase,
          job_id:       self.id,
          old_count_id: self.count.parent_id,
          new_count_id: self.count.id
        }
      }

      payload.merge!(
        old_selects: selects_for_cloning(self.count.parent),
        new_selects: selects_for_cloning(self.count)
      )
      payload
    end

    def save_result_values
      save
      self.count.save
    end

    private
      def selects_for_cloning(count)
        count.selects.active.map { |sel| { select_id: sel.id } }
      end
  end
end
