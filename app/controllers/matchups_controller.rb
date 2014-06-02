class MatchupsController < ApplicationController
	def index
		if is_admin_user
      Rails.logger.debug("(MatchupsController.index) is admin")
      @week = Week.find(params[:week_id])
      @matchups = Matchup.where(week: @week)

      respond_to do | format |
        format.json {render json: @matchups}
      end
    else
      Rails.logger.error("(MatchupsController.index) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end
		
	end
end