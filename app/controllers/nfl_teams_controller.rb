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

  def show

    if is_admin_user
      Rails.logger.debug("(NflTeamsController.show) is admin")
      @nfl_team = NflTeam.where(id: params[:id]).first

      respond_to do | format |
        format.json {render json: @nfl_team}
      end
    else
      Rails.logger.debug("(NflTeamsController.show) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end

  end


  def update

    if is_admin_user
      Rails.logger.debug("(NflTeamsController.update) is admin")
      @nfl_team = NflTeam.where(id: params[:id]).first

      # Todo setup the permitted attributes for Rails 4
      @nfl_team.update_attributes(params)

      if @nfl_team.save()
        respond_to do | format |
          format.json {render json: @nfl_team}
        end
      else
        Rails.logger.error("TODO return a server errror")
        respond_to do | format |
          format.json { render :json => [], :status => :unauthorized }
        end
      end

    else
      Rails.logger.debug("(NflTeamsController.update) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end

  end

end