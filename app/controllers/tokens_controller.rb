class TokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user_from_token!, only: [:create, :destroy]
  skip_before_filter :authenticate_user!, only: [:create, :destroy]
  before_filter :require_json_request
  before_filter :validate_parameters, only: [:create]
  before_filter :require_proper_credentials, only: [:create]
  before_filter :require_existing_user, only: [:create]
  before_filter :validate_password, only: [:create]

  respond_to :json

  def create
    last_sign_in_at = @user.last_sign_in_at || DateTime.now

    token = Token.new()
    token.token = @user.authentication_token
    token.user = @user
    sign_in(@user)

    render :json => token

  end

  def destroy
    @user=User.find_by_authentication_token(params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:id]}
    end
  end

  def verify
    head :no_content
  end

  private

    def require_json_request
      if request.format != :json
        render :status=>406, :json=>{:message=>"The request must be json"}
      end
    end

    def require_proper_credentials
      @email = @user['email']
      @password = @user['password']

      if @email.nil? or @password.nil?
        logger.error("Both email and password must be supplied")
        render :status=>400,
                :json=>{:message=>"Missing Credentials."}
      end
    end

    def require_existing_user
      @user=User.find_by_email(@email.downcase)
      if @user.nil?
        Rails.logger.error("User #{@email} failed signin, user cannot be found.")
        render :status=>401, :json=>{:message=>"Invalid Credentials."}
      end
    end

    def validate_password
      @user.ensure_authentication_token

      if not @user.valid_password?(@password)
        logger.error("User #{@email} failed signin, password is invalid")
        render :status=>401, :json=>{:message=>"Invalid Credential."}
      end
    end

    def validate_parameters
      @validated_params = params.permit(:user => [:email, :password], :registration => [ :registration_id, :app_name, :device_id, :device_os ])
      @user = @validated_params[:user]
      @registration = @validated_params[:registration]
    end
end