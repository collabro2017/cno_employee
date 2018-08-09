module ChainJobStatus
  # Decorate status method for running the status change check and DB update
  def status
    if self.new_record?
      :created
    else
      db_status = super

      # NOTE: self.class.status checks the status at Resque and syncs w/ DB
      reload if db_status.active? && db_status != self.class.status(id)

      super
    end
  end
end