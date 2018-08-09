module Jobs
  class Count < Job

    def payload
      base_payload
    end

    def save_result_values
      super
    end
  end
end
