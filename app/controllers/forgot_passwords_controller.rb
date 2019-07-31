class ForgotPasswordsController < Devise::PasswordsController

	def create
		@user = User.where(email: params[:user_email]).first

		if @user
			@user.send_reset_password_instructions

			respond_to do | format |
				format.json { render json: @user }
			end
			
		else

			respond_to do | format |
				error_message = "There is no user associated with that email."
				format.json {render json: [error: error_message], :status => :bad_request}
			end
		  
		end
	end

	def update
		resource_params = params
		self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
	end

end