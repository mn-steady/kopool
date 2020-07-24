class UserMailer < ActionMailer::Base
  default from: "daveandtree@comcast.net"

  def welcome_email(user)
    @user = user
    @url  = 'https://www.kopool.org'

    web_state = WebState.first
    if web_state.nil?
      @season_name = "Testing Season KOPool"
    else
      @season_name = web_state.current_week.season.name ||= "KOPool"
    end

    mail(to: @user.email, subject: 'Welcome to the KOPool')
  end

end
