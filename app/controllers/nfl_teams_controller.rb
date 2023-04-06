class NflTeamsController < ApplicationController

  before_action :verify_admin_user, only: [:show, :update, :create, :destroy]
  before_action :verify_any_user, only: [:index]

  def index
    @nfl_teams = NflTeam.all

    respond_to do | format |
      format.json {render json: @nfl_teams, :methods => [:logo_url_small]}
    end
  end

  def show

    Rails.logger.debug("(NflTeamsController.show) is admin")
    @nfl_team = NflTeam.where(id: params[:id]).first

    respond_to do | format |
      format.json {render json: @nfl_team}
    end

  end


  def update

    Rails.logger.debug("(NflTeamsController.update) is admin")
    @nfl_team = NflTeam.where(id: params[:id]).first

    # Todo setup the permitted attributes for Rails 4
    cleaned_params = nfl_teams_params
    Rails.logger.debug("Cleaned Params: #{cleaned_params}")
    if @nfl_team.update(cleaned_params)
      respond_to do | format |
        format.json {render json: @nfl_team}
      end
    else
      respond_to do | format |
        format.json { render :json => [], :status => :internal_server_error }
      end
    end

  end


  def destroy

    Rails.logger.debug("(NflTeamsController.destroy) is admin")
    @nfl_team = NflTeam.where(id: params[:id]).first

    # Todo setup the permitted attributes for Rails 4

    if @nfl_team.delete()
      respond_to do | format |
        format.json {render json: @nfl_team}
      end
    else
      respond_to do | format |
        format.json { render :json => [], :status => :internal_server_error }
      end
    end

  end


  def create

    Rails.logger.debug("(NflTeamsController.create) is admin")
    @nfl_team = NflTeam.new()

    # Todo setup the permitted attributes for Rails 4
    @nfl_team.update(nfl_teams_params)

    if @nfl_team.save()
      respond_to do | format |
        format.json {render json: @nfl_team}
      end
    else
      respond_to do | format |
        format.json { render :json => [], :status => :internal_server_error }
      end
    end

  end

private

  def nfl_teams_params
    params.require(:nfl_team).permit(:name, :conference, :division, :color, :abbreviation, :home_field, :website, :logo, :wins, :losses, :ties, :logo)
  end

end

