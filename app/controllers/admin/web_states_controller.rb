class Admin::WebStatesController < ApplicationController
  before_action :verify_admin_user, only: [:show]

  def show
    Rails.logger.debug("(WebStatesController.show)")
    @web_state = WebState.first
    respond_to do | format |
      format.json {render json: @web_state}
    end
  end

private

  def webstate_params
    params.permit(:id, :current_week, :open_for_registration)
  end

end