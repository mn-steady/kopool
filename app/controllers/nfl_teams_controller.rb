class NflTeamsController < ApplicationController

  def index

    @nfl_teams = NflTeam.all

    respond_to do | format |
      format.json {render json: @nfl_teams}
    end

  end

end