class MatchupsController < ApplicationController
	def index
		if is_admin_user
      Rails.logger.debug("(MatchupsController.index) is admin")
      @week = Week.find(params[:week_id])
      @matchups = Matchup.where(week: @week)

      respond_to do | format |
        format.json {render :json => @matchups.to_json(include: [{ home_team: { only: [:name, :id] }}, away_team: {only: [:name, :id]}] ) }
      end
    else
      Rails.logger.error("(MatchupsController.index) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end
	end

  def show
    @matchup = Matchup.where(id: params[:id]).first

    respond_to do |format|
      format.json {render :json => @matchup.to_json(include: [{ home_team: { only: [:name, :id] }}, away_team: {only: [:name, :id]}] ) }
    end
  end

  def update
    Rails.logger.debug("(MatchupsController.update) is admin")
    @matchup = Matchup.where(id: params[:id]).first

    # Todo setup the permitted attributes for Rails 4
    cleaned_params = matchups_params
    Rails.logger.debug("Cleaned Params: #{cleaned_params}")
    if @matchup.update_attributes(cleaned_params)
      respond_to do | format |
        format.json {render json: @matchup.to_json(include: [{ home_team: { only: [:name, :id] }}, away_team: {only: [:name, :id]}] )}
      end
    else
      respond_to do | format |
        format.json { render :json => [], :status => :internal_server_error }
      end
    end
  end

  private

    def matchups_params
      params.require(:matchup).permit(:home_team_id, :away_team_id, :game_time, :week_id, :completed, :tie, :winning_team_id)
    end
end