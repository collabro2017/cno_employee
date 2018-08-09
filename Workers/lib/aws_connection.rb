require 'aws-sdk'

class AwsConnection
  
  def self.aws_access_id
    return @@aws_access_id if defined?(@@aws_access_id)

    @@aws_access_id = ENV['AWS_ACCESS_KEY_ID']
  end

  def self.aws_secret_key
    return @@aws_secret_key if defined?(@@aws_secret_key)

    @@aws_secret_key = ENV['AWS_SECRET_ACCESS_KEY']
  end

  def self.s3
    return @@s3 if defined?(@@s3)

    AWS.config(
      access_key_id: self.aws_access_id,
      secret_access_key: self.aws_secret_key
    )
    @@s3 = AWS::S3.new     
  end

  def self.sns
    return @@sns if defined?(@@sns)

    @@sns = AWS::SNS.new(
      access_key_id: self.aws_access_id,
      secret_access_key: self.aws_secret_key
    )
  end
end