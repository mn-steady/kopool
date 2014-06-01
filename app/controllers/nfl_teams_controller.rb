class NflTeamsController < ApplicationController

  def index

    if is_admin_user
      Rails.logger.debug("(NflTeamsController.index) is admin")
      @nfl_teams = NflTeam.all

      respond_to do | format |
        format.json {render json: @nfl_teams, :methods => [:logo_url_small]}
      end
    else
      Rails.logger.error("(NflTeamsController.index) unauthorized")
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
      cleaned_params = nfl_teams_params
      Rails.logger.debug("Cleaned Params: #{cleaned_params}")
      @nfl_team.update_attributes(cleaned_params)

      # TODO: this is redundant
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


  def destroy

    if is_admin_user
      Rails.logger.debug("(NflTeamsController.destroy) is admin")
      @nfl_team = NflTeam.where(id: params[:id]).first

      # Todo setup the permitted attributes for Rails 4

      if @nfl_team.delete()
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
      Rails.logger.debug("(NflTeamsController.destroy) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end

  end


  def create

    if is_admin_user
      Rails.logger.debug("(NflTeamsController.create) is admin")
      @nfl_team = NflTeam.new()

      # Todo setup the permitted attributes for Rails 4
      @nfl_team.update_attributes(nfl_teams_params)

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

private

  def nfl_teams_params
    # This is totally cheezy but have no access to docs in the car...
    # params.delete_if { |k,v| ['id','created_at','updated_at','format','nfl_team'].include?(k)  }
    # params.permit(:name, :conference, :division, :color, :abbreviation, :home_field, :website, :logo, :wins, :losses, :ties, :logo)
    params.require(:nfl_team).permit(:name, :conference, :division, :color, :abbreviation, :home_field, :website, :logo, :wins, :losses, :ties, :logo)
  end

end

