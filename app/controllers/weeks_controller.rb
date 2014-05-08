class WeeksController < ApplicationController
  def index
  	@weeks = Week.where(season_id: params[:season_id])

  	respond_to do | format |
  		format.json { render json: @weeks }
  	end
  end
end