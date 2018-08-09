require_relative 'configuration'
require_relative 'ftp_connection'
require_relative 'aws_connection'

class FileTransfer

  def self.send_file(user:, host:, source:, destination:)
    if Configuration.environment == 'development'
      FileUtils.mkdir_p(destination)
      FileUtils.cp(source, destination)
    else
      options = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q'
      `ssh #{options} #{user}@#{host} "mkdir -p #{destination}"`
      `scp -c arcfour #{options} -C #{source} #{user}@#{host}:#{destination}`
    end
  end

  def self.upload_to_ftp(filename:, user_email:, ftp_server:)
    if ftp_server.in_local_network
      user_dir = "/var/ftp/#{user_email}/orders/"
      ftp_host = ftp_server.private_address

      send_file(
        user: 'ftp',
        host: ftp_host,
        source: filename,
        destination: user_dir
      )
      log.info "Sending file to LOCAL ftp server"
    else
      #TO-DO: logic to handle the sending method to a remote ftp server
      log.warn "TO-DO: Send file to REMOTE ftp server (missing code)"
    end

    "ftp://#{ftp_server.public_address}/orders/#{File.basename(filename)}"
  end

  def self.upload_to_s3(bucket:, filename:, user_email:)
    s3 = AwsConnection.s3

    create_bucket(bucket: bucket) unless s3.buckets[bucket].exists?

    key = "#{user_email}/orders/#{File.basename(filename)}"

    s3.buckets[bucket].objects[key].write(file: filename)
    uploaded_file = s3.buckets[bucket].objects[key]

    options = {
      expires: Configuration.numbers['aws_expire_time'],
      response_content_type: "application/zip"
    }

    uploaded_file.url_for(:read, options).to_s
  end

  def self.download_from_s3(domain:, file_id:, user_email:, file_name:)
    bucket = "rb-#{domain}"
    key = "#{user_email}/uploads/#{file_name}"
    s3 = AwsConnection.s3

    original_file = s3.buckets[bucket].objects[key]

    central_ds_output_path = Configuration.paths['central_ds_output_path']
    download_path = File.join(central_ds_output_path, domain)

    filename = "/user_file_#{file_id}#{File.extname(file_name)}"
    local_file = File.join(download_path, filename)

    File.delete(local_file) if File.exists?(local_file)

    File.open(local_file, 'wb') do |file|
      original_file.read do |chunk|
        file.write(chunk)
      end
    end

    local_file
  end

  def self.get_header_from_s3(domain:, file_id:, user_email:, file_name:)
    header = []
    bucket = "rb-#{domain}"

    if File.extname(file_name) != ".zip"
      key = "#{user_email}/uploads/#{file_name}"

      AwsConnection.s3.buckets[bucket].objects[key].read do |chunk|
        header = StringIO.new(chunk).readline.strip.split(',')
        break
      end
    else
      begin
        local_file = download_from_s3(
          domain: domain,
          file_id: file_id,
          user_email: user_email,
          file_name: file_name
        )

        IO.popen("unzip -p #{local_file} | head -1") do |io|
          header = io.gets.strip.split(',')
        end
      ensure
        File.delete(local_file) if File.exists?(local_file)
      end
    end

    header
  end

  def self.create_bucket(bucket:)
    s3 = AwsConnection.s3

    unless s3.buckets[bucket].exists?
      s3.buckets.create(bucket)

      cors_rules = {
        allowed_origins: %w(*),
        allowed_methods: %w(GET PUT POST),
        allowed_headers: %w(*)
      }

      s3.buckets[bucket].cors.add(cors_rules)
    end
  end

  #Alias
  def self.log; Configuration.logger; end
end
