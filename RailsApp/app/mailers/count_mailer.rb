class CountMailer < ActionMailer::Base
  default from: "cno@runawaybit.com"
  
  def breakdown_report(user, count, result)
    @user = user
    @result = result
    mail(to: @user.email, subject: "Breakdown of #{count.name}")
  end
  
end
