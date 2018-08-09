module Classes
  module Job
    def job_key_prefix
      namespace = Classes::Field::NAMESPACE
      "#{namespace}:#{@header_struct.domain}:j#{@header_struct.job_id}"
    end
  end
end