class UserMailer < ActionMailer::Base
  default from: "daveandtree@comcast.net"

  def welcome_email(user)
    @user = user
    @url  = 'http://kopool.herokuapp.com'
    mail(to: @user.email, subject: 'Welcome to the KOPool')
  end

end
