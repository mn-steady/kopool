class ForgotPasswordsController < Devise::PasswordsController
	
	def create
		@user = User.where(email: params[:user_email]).first
		if user
			user.send_reset_password_instructions

			respond_to do | format |
				format.json {render json: @user}
			end
			
		else

			respond_to do | format |
				error_message = "No user found for email #{params[:user_email]}"
				format.json { render :json => [:error =>  error_message], :status => :internal_server_error}
			end
		  
		end
	end

end