class ForgotPasswordsController < Devise::PasswordsController

	def create

		@user = User.where(email: params[:user_email]).first

		if @user
			@user.send_reset_password_instructions

			respond_to do | format |
				format.json {render json: @user}
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
		super

		# @user = User.reset_password_by_token(params[:reset_password_token])

		# if @user.errors.empty?
  #     @user.unlock_access! if unlockable?(@user)
  #     flash_message = @user.active_for_authentication? ? :updated : :updated_not_active
  #     set_flash_message(:notice, flash_message) if is_flashing_format?
  #     sign_in(@user_name, @user)
  #     respond_with @user, location: after_resetting_password_path_for(@user)
  #   else
  #     respond_with @user
  #   end
	end

	def forgot_password_params

	end

end