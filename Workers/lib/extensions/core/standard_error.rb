class StandardError

  if instance_methods.map(&:to_s).include?('clean_message')
    fail '#clean_message already defined on Standard Error'
  end

  def clean_message(path)
    clean_backtrace = self.backtrace.select { |s| /^\s*#{path}.*$/ =~ s }

    msg = "#{self.class.name}: #{self.message}"
    msg << "\n\t#{clean_backtrace.join("\n\t")}"
  end

end