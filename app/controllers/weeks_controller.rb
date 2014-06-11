class WeeksController < ApplicationController
  before_action :verify_any_user, only: [:index]
  before_action :verify_admin_user, only: [:update, :destroy, :create]

  def index
    if is_any_user
    	@weeks = Week.where(season_id: params[:season_id]).order('season_id, week_number')
    	respond_to do | format |
    		format.json { render json: @weeks }
    	end
    else
      Rails.logger.debug("(WeeksController.index) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end
  end


  def show
    Rails.logger.debug("(WeeksController.show)")
    @week = Week.where(id: weeks_params[:id]).where(season_id: weeks_params[:season_id]).first
    respond_to do | format |
      format.json {render json: @week}
    end
  end


  def create
    Rails.logger.debug("(Weeks.create)")
    @week = Week.new()

    @week.update_attributes(weeks_params)

    if @week.save()
      respond_to do | format |
        format.json {render json: @week}
      end
    else
      respond_to do | format |
        error_message = ""
        @week.errors.each{|attr,msg| error_message << "#{attr} #{msg} " }
        format.json { render :json => [:error => error_message], :status => :internal_server_error}
      end
    end
  end


  def update
    Rails.logger.debug("(WeeksController.update)")
    @week = Week.where(id: params[:id]).first

    cleaned_params = weeks_params
    Rails.logger.debug("Cleaned Params: #{cleaned_params}")
    if @week.update_attributes(cleaned_params)
      respond_to do | format |
        format.json {render json: @week}
      end
    else
      respond_to do | format |
        @week.errors.each{|attr,msg| error_message << "#{attr} #{msg} " }
        format.json { render :json => [:error => error_message], :status => :internal_server_error }
      end
    end
  end


  def destroy
    Rails.logger.debug("(WeeksController.destroy) is admin")
    @week = Week.where(id: params[:id]).first

    if @week.delete()
      respond_to do | format |
        format.json {render json: @week}
      end
    else
      respond_to do | format |
        @week.errors.each{|attr,msg| error_message << "#{attr} #{msg} " }
        format.json { render :json => [:error => error_message], :status => :internal_server_error }
      end
    end
  end


  def close_week!
    @week = Week.find(params[:id])
    @week.close_week_for_picks!
  end

  def next_week!
    @week = Week.find(params[:id])
    @week.move_to_next_week
  end

private

  def weeks_params
    params.permit(:id, :week_number, :start_date, :end_date, :deadline, :season_id)
  end

end