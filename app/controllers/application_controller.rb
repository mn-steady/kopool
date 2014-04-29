class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :require_user, :require_admin

  def require_user
  	if !user_signed_in?
  		flash[:notice] = "Please sign in!"
  		redirect_to new_user_session_path
  	end
  end

  def require_admin
  	unless current_user.admin?
  		flash[:danger] = "You are not authorized to do that. Contact the commish if you have any questions."
  		redirect_to root_path
  	end
  end
end
