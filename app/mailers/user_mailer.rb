class UserMailer < ActionMailer::Base
  default :from => "jmharris9@gmail.com"

  def registration_confirmation(user)
  	@user = user
    mail(:to => user.email, :subject => "Registration Confirmation")
  end

  def following_notification(user, follower)
  	@user = user
  	@follower = follower
  	mail(:to => user.email, :subject => "New Follower!")
  end

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset"
  end
end