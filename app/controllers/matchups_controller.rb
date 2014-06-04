class MatchupsController < ApplicationController
	def index
		if is_admin_user
      Rails.logger.debug("(MatchupsController.index) is admin")
      @week = Week.find(params[:week_id])
      @matchups = Matchup.where(week: @week)

      respond_to do | format |
        format.json {render :json => @matchups.to_json(include: [{ home_team: { only: :name }}, away_team: {only: :name}] ) }
      end
    else
      Rails.logger.error("(MatchupsController.index) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end
		
	end
end