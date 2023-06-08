class Commissioner::WebStatesController < ApplicationController
  before_action :verify_admin_user, :set_current_week, only: :update
  skip_before_action :authenticate_user_from_token!
    # This is Devise's authentication
  skip_before_action :authenticate_user!

  def show
    @web_state = WebState.first
    respond_to do | format |
      # Jack: If you want to know what a "Law of demeter violation" is... This is it!
      format.json {render :json => @web_state.to_json(
        include: [
          { current_week: 
            { only: 
              [:id, :open_for_picks, :week_number]
            }
          }, 
          { current_season: 
            { only: 
              [:id, :year, :name, :open_for_registration]
            }
          }
        ]
      )}
    end
  end

  def update
    cleaned_params = webstate_params.except(:current_week).merge(current_week: @current_week)
    Rails.logger.debug("Cleaned Params: #{cleaned_params}")
    @web_state = WebState.first
    if @web_state.update(cleaned_params)
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

  def set_current_week
    @current_week = Week.find_by(id: params.dig(:current_week, :id))
  end
end
