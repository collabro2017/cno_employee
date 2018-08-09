class UserMailer < ActionMailer::Base

  def activation_email(user, sender, url)
    app_name = CNO::RailsApp.config.custom.app_name
    common_mail(user, sender, url, "Welcome to #{app_name}")
  end

  def password_reset_email(user, sender, url)
    common_mail(user, sender, url, "Password Reset")
  end

  def send_auth_token user        
    @user = user

    mail(
        from: ENV['ACTIVATION_EMAIL_FROM'],
        to: user.email,
        bcc: 'pam@pensaconsulting.com',
        subject: "Authentication Token"
      )
  end

  private
    def common_mail(user, sender, url, subject)
      params = {activation_token: user.activation_token}
      @user = user
      @url = url + "?#{params.to_query}"
      
      mail(
        from: sender,
        to: @user.email,
        bcc: 'pam@pensaconsulting.com',
        subject: subject
      )
    end
end
