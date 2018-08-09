namespace :data_conversion do
  # desc "TODO"
  task :email_conversion => :environment do
    User.where(userid: nil).each do |u|
      rand_num = rand(1..100).to_s
      if User.where(userid: u.email).any?        
        u.userid = u.email.sub("@", rand_num + "@")
      else
        u.userid = u.email
      end

      begin
        u.save!        
      rescue Exception => e
        puts "============= Exception - Rake data_conversion -> email_conversion ============="
        puts e.message
      end

    end
  end

end