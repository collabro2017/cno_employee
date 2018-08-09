class FtpConnection 

  def self.host
    return @@ftp_host if defined?(@@ftp_host)

    @@ftp_host = (ENV['FTP_HOST'] || 'ftp_server')
  end

end
