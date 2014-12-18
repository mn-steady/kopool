class ApplicationController < ActionController::Base
  protect_from_forgery #with: :exception
  include TokenAuthentication
  helper_method :require_user, :require_admin

  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    Rails.logger.debug("set_csrf_cookie_for_ng called FAT:#{form_authenticity_token}")
    Rails.logger.debug("protect_against_forgery = #{protect_against_forgery?}")
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def require_user
    Rails.logger.debug("require_user method in application controller")
  	if !user_signed_in?
  		flash[:notice] = "Please sign in!"
  		redirect_to new_user_session_path
  	end
  end

  def is_admin_user
    return false if current_user.nil?
    return current_user.admin?
  end

  def is_any_user
    return false if current_user.nil?
    return user_signed_in?
  end

  def verify_admin_user
    unless is_admin_user
      Rails.logger.debug("Unauthorized - Must be Admin")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end
  end

  def verify_any_user
    unless user_signed_in?
      Rails.logger.debug("Unauthorized - Must be Logged-in")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end
  end

  protected

  def verified_request?
    Rails.logger.debug("verified_request called f_a_t:#{form_authenticity_token}. X-XSRF-TOKEN:#{request.headers['X-XSRF-TOKEN']}")
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end
end
