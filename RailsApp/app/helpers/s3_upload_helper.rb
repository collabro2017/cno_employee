module S3UploadHelper
  def current_user_s3_direct_post
    unless current_user.nil?
      AWS::S3.new.buckets[CNO::RailsApp.config.custom.s3bucket].presigned_post(
        key: "#{current_user.email}/uploads/${filename}",
        success_action_status: 201, 
        acl: :public_read
      )
    end
  end

  def remove_s3_key(key)
      bucket = AWS::S3.new.buckets[CNO::RailsApp.config.custom.s3bucket]

      bucket.objects[key].delete

      !bucket.objects[key].exists?
  end
end
