class NflTeamsController < ApplicationController

  def index

    if is_admin_user
      Rails.logger.debug("(NflTeamsController.index) is admin")
      @nfl_teams = NflTeam.all

      respond_to do | format |
        format.json {render json: @nfl_teams}
      end
    else
      Rails.logger.debug("(NflTeamsController.index) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end

  end

end