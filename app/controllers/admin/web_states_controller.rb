class Admin::WebStatesController < ApplicationController
  before_action :verify_admin_user, only: :update

  def show
    @web_state = WebState.first
    respond_to do | format |
      format.json {render :json => @web_state.to_json(include: [{ current_week: { only: [:open_for_picks] }}])}
    end
  end

  def update
    cleaned_params = webstate_params
    Rails.logger.debug("Cleaned Params: #{cleaned_params}")
    @web_state = WebState.first
    if @web_state.update_attributes(cleaned_params)
      respond_to do | format |
        format.json {render json: @web_state}
      end
    else
      respond_to do | format |
        format.json { render :json => [], :status => :internal_server_error }
      end
    end
  end

private

  def webstate_params
    params.permit(:id, :current_week, :open_for_registration, :broadcast_message)
  end

end