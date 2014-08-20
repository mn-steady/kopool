class WeeksController < ApplicationController
  before_action :verify_any_user, only: [:index, :week_results]
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
    # TODO: DC and JC discuss.  If we've got an actual id (not week number) there is no reason we also need
    # the season.  Removed: where(season_id: weeks_params[:season_id])
    @week = Week.where(id: weeks_params[:id]).first
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
    @week = Week.find(params[:week_id])
    @week.close_week_for_picks!
    render json: @week
  end

  def reopen_week!
    @week = Week.find(params[:week_id])
    if @week.reopen_week_for_picks!
      render json: @week
    else
      error_message = "Cannot reopen week"
      render :json => [:error => error_message], :status => :internal_server_error
    end
  end

  def next_week!
    @week = Week.find(params[:week_id])
    if @week.move_to_next_week!
      render json: @week
    else
      Rails.logger.error("ERROR could not advance week")
      error_message = "Cannot advance week"
      render :json => [:error => error_message], :status => :internal_server_error
    end
  end

  def week_results
    Rails.logger.debug("weeks_controller.week_results")
    @webstate = WebState.first
    @week = Week.find(params[:week_id])

    if @week.week_number > @webstate.current_week.week_number
      Rails.logger.error("ERROR can't look at a future week's results")
      error_message = "You cannot view the results of a future week. Nice try!"
      render :json => [:error => error_message], :status => :bad_request
    elsif @week.open_for_picks == true
      Rails.logger.error("ERROR can't see this weeks results until the week is closed for picks")
      error_message = "You can't see the results for this week until this week's games have started."
      render :json => [:error => error_message], :status => :bad_request
    else
      @pool_entries_knocked_out_this_week = []
      @pool_entries_still_alive = []
      @pool_entries_knocked_out_previously = []
      @unmatched_pool_entries = []

      @season = @week.season
      Rails.logger.debug("(weeks_controller.week_results) checking seasion #{@season.id} week id:#{@week.id}")
      @pool_entries_this_season = PoolEntry.where(season_id: @season.id).order('team_name ASC')
      Rails.logger.debug("(weeks_controller.week_results) have #{@pool_entries_this_season.count} pool entries")

      @pool_entries_this_season.each do |pool_entry|

        Rails.logger.debug("(weeks_controller.week_results) Examining Pool Entry #{pool_entry.id}")

        @returned_pool_entry = {}
        @returned_pool_entry[:id] = pool_entry.id
        @returned_pool_entry[:team_name] = pool_entry.team_name
        @returned_pool_entry[:nfl_team] = pool_entry.most_recent_picks_nfl_team(@week)

        @pool_entries_still_alive.push(@returned_pool_entry) unless pool_entry.knocked_out

        if pool_entry.knocked_out and pool_entry.knocked_out_week_id == @week.id
          @pool_entries_knocked_out_this_week.push(@returned_pool_entry)
        end

        if pool_entry.knocked_out and pool_entry.knocked_out_week_id != @week.id
          @pool_entries_knocked_out_previously.push(@returned_pool_entry)
        end

      end
      @week_results = [@pool_entries_still_alive, @pool_entries_knocked_out_this_week, @pool_entries_knocked_out_previously, @unmatched_pool_entries]

      respond_to do | format |
        format.json {render :json => @week_results.to_json}
      end
    end
  end

  def unpicked
    Rails.logger.debug("weeks_controller.unpicked")
    @webstate = WebState.first
    @week = Week.find(params[:week_id])
    @season = @week.season

    @this_weeks_picks = Pick.where(week_id: params[:week_id])
    @active_pool_entries = PoolEntry.where(knocked_out: false).where(season_id: @season.id)
  end

private

  def weeks_params
    params.permit(:id, :week_number, :start_date, :end_date, :deadline, :season_id, :week)
  end

end