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

end