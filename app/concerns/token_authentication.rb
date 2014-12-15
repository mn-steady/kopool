module TokenAuthentication
  extend ActiveSupport::Concern

  # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6

  included do
    private :authenticate_user_from_token!
    # This is our new function that comes before Devise's one
    before_filter :authenticate_user_from_token!
    # This is Devise's authentication
    before_filter :authenticate_user!
  end


  def authenticate_user_from_token!
    Rails.logger.debug("(TokenAuthentication.authenticate_user_from_token!)")
    user_token = request.headers["X-User-Token"]
    user_email = request.headers["X-User-Email"]

    user = user_email && User.where(email: user_email).first

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, user_token)
      # If you want the token to work as a sign in token, you can simply remove store: false.
      Rails.logger.debug("(TokenAuthentication.authenticate_user_from_token!) signing in")
      sign_in user, store: false
    end
  end

  module ClassMethods
    # nop
  end
end