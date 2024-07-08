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

    @week.update(weeks_params)

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
    if @week.update(cleaned_params)
      respond_to do | format |
        format.json {render json: @week}
      end
    else
      respond_to do |format|
        error_message = ""
        @week.errors.each { |attr, msg| error_message << "#{attr} #{msg} " }
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
        error_message = ""
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
      @season = @week.season
      locked_matchups = Matchup.where(week_id: @week.id, locked: true)
      @locked_picks = Pick.includes(:pool_entry).where(pool_entries: {season_id: @season.id}).where(matchup_id: locked_matchups.map(&:id))

      if @locked_picks.present?
        locked_pool_entry_ids = @locked_picks.pluck(:pool_entry_id)
        @pool_entries_knocked_out_this_week = []
        @pool_entries_still_alive = []
        @pool_entries_knocked_out_previously = []
        @unmatched_pool_entries = []

        @pool_entries_this_season = PoolEntry.includes(:picks).where(season_id: @season.id).distinct.order('picks.id ASC')
        @pool_entries_this_season.each do |pool_entry|

          @returned_pool_entry = {}
          @returned_pool_entry[:id] = pool_entry.id
          @returned_pool_entry[:team_name] = pool_entry.team_name
          if locked_pool_entry_ids.include?(pool_entry.id)
            @returned_pool_entry[:nfl_team] = pool_entry.most_recent_picks_nfl_team(@week)
          end

          @pool_entries_still_alive.push(@returned_pool_entry) unless pool_entry.knocked_out

          if pool_entry.knocked_out and pool_entry.knocked_out_week_id == @week.id
            @pool_entries_knocked_out_this_week.push(@returned_pool_entry)
          end

          if pool_entry.knocked_out and pool_entry.knocked_out_week_id != @week.id
            @pool_entries_knocked_out_previously.push(@returned_pool_entry)
          end
        end
        @pool_entries_knocked_out_previously = @pool_entries_knocked_out_previously.sort_by { |entry| entry[:team_name] }
        @unmatched_pool_entries = @unmatched_pool_entries.sort_by { |entry| entry[:team_name] }
        @week_results = [@pool_entries_still_alive, @pool_entries_knocked_out_this_week, @pool_entries_knocked_out_previously, @unmatched_pool_entries]

        respond_to do | format |
          format.json {render :json => @week_results.to_json}
        end
      else
        Rails.logger.error("ERROR can't see this weeks results until the week is closed for picks")
        error_message = "You can't see the results for this week until this week's games have started."
        render :json => [:error => error_message], :status => :bad_request
      end
    else
      @pool_entries_knocked_out_this_week = []
      @pool_entries_still_alive = []
      @pool_entries_knocked_out_previously = []
      @unmatched_pool_entries = []

      @season = @week.season
      Rails.logger.debug("(weeks_controller.week_results) checking seasion #{@season.id} week id:#{@week.id}")
      @pool_entries_this_season = PoolEntry.includes(:picks).where(season_id: @season.id).distinct.order('picks.id ASC')
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
      @pool_entries_knocked_out_previously = @pool_entries_knocked_out_previously.sort_by { |entry| entry[:team_name] }
      @unmatched_pool_entries = @unmatched_pool_entries.sort_by { |entry| entry[:team_name] }
      @week_results = [@pool_entries_still_alive, @pool_entries_knocked_out_this_week, @pool_entries_knocked_out_previously, @unmatched_pool_entries]

      respond_to do | format |
        format.json {render :json => @week_results.to_json}
      end
    end
  end

  def unpicked
    Rails.logger.debug("weeks_controller.unpicked week: #{params[:week_id]}")
    @week = Week.find(params[:week_id])
    @season = @week.season

    @unpicked_pool_entries = PoolEntry.where(knocked_out: false).where(season_id: @season.id).where("pool_entries.id NOT IN (SELECT picks.pool_entry_id FROM picks where week_id = #{@week.id})")

    respond_to do | format |
      format.json {render :json => @unpicked_pool_entries.to_json(include: [{user: {only: [:name, :phone, :email]}}])}
    end
  end

  def locked_picks
    @week = Week.find(params[:week_id])
    @season = @week.season

    locked_matchups = Matchup.where(week_id: @week.id, locked: true)

    @locked_picks = Pick.includes(:pool_entry).where(pool_entries: {knocked_out: false, season_id: @season.id}).where(matchup_id: locked_matchups.map(&:id))

    respond_to do | format |
      format.json {render :json => @locked_picks.to_json(
        include: [
          {pool_entry: { only: [:id, :team_name]}},
          {nfl_team: {only: [:name]}},
          {user: {only: [:name]}}
        ]
      )}
    end
  end

private

  def weeks_params
    params.permit(:id, :week_number, :start_date, :end_date, :deadline, :season_id, :week)
  end

end