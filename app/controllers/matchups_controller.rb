class MatchupsController < ApplicationController
	before_filter :verify_admin_user, only: [:show, :update, :save_week_outcomes, :destroy, :create]
  before_filter :verify_any_user, only: [:index, :filtered_matchups]

  def index

    @week = Week.find(params[:week_id])
    @matchups = Matchup.where(week_id: @week.id).order('game_time')

    respond_to do | format |
      format.json {render :json => @matchups.to_json(include: [{ home_team: { only: [:name, :id], :methods => [:logo_url_small] }}, away_team: {only: [:name, :id], :methods => [:logo_url_small]}] ) }
    end
	end

  def filtered_matchups
    @week = Week.find(params[:week_id])

    if @week.open_for_picks == true
      @season = @week.season
      locked_matchups = Matchup.where(week_id: @week.id, locked: true)
      @locked_picks = Pick.includes(:pool_entry).where(pool_entries: {season_id: @season.id}).where(matchup_id: locked_matchups.map(&:id))
      if @locked_picks.present?
        @filtered_matchups = Matchup.where(week_id: @week.id, id: @locked_picks.map(&:matchup_id))

        respond_to do |format|
          format.json {render :json => @filtered_matchups.to_json(include: [{home_team: { only: [:name, :id], :methods => [:logo_url_small] }}, away_team: {only: [:name, :id], :methods => [:logo_url_small]}])}
        end
      else
        Rails.logger.error("ERROR You cannot view the picks for this week until the games start! Week must be closed for picks")
        error_message = "You cannot view the picks for this week until the games start!"
        render :json => [:error => error_message], :status => :bad_request
      end
    else
      @this_weeks_picks = Pick.where(week_id: @week.id)
      @matchups_this_week = Matchup.where(week_id: @week.id)
      @filtered_matchups = []

      @matchups_this_week.each do |matchup|
        @this_weeks_picks.each do |pick|
          if pick.team_id == matchup.home_team_id || pick.team_id == matchup.away_team_id
            @filtered_matchups.push(matchup)
          end
        end
      end

      @filtered_matchups.uniq!

      respond_to do |format|
        format.json {render :json => @filtered_matchups.to_json(include: [{home_team: { only: [:name, :id], :methods => [:logo_url_small] }}, away_team: {only: [:name, :id], :methods => [:logo_url_small]}])}
      end
    end



  end

  def show
    @matchup = Matchup.where(id: params[:id]).first

    respond_to do |format|
      format.json {render :json => @matchup.to_json(include: [{ home_team: { only: [:name, :id, :logo_url_small] }}, away_team: {only: [:name, :id, :logo_url_small]}] ) }
    end
  end

  def create
    Rails.logger.debug("(Matchups.create)")
    @matchup = Matchup.new()

    @matchup.update_attributes(matchups_params)

    if @matchup.save()
      respond_to do | format |
        format.json {render json: @matchup}
      end
    else
      respond_to do | format |
        error_message = ""
        @matchup.errors.each{|attr,msg| error_message << "#{attr} #{msg} " }
        format.json { render :json => [:error => error_message], :status => :internal_server_error}
      end
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

  def save_outcome
    Rails.logger.debug("in save_outcome method")

    Matchup.handle_matchup_outcome!(params[:matchup][:id])

    respond_to do |format|
      format.json {render :json => @picks_this_week.to_json(include: {pool_entry: {only: [:team_name]} } ) }
    end
  end

  def destroy
    Rails.logger.debug("in delete matchups method")
    @matchup = Matchup.find_by(id: params[:id])

    if @matchup.picks.count > 0
      respond_to do |format|
        error_message = "Matchup cannot be deleted! There are picks associated with this matchup."
        format.json { render :json => [:error => error_message], :status => :internal_server_error }
      end
    end

    if @matchup.delete
      respond_to do |format|
        format.json {render json: @matchup }
      end
    else
      respond_to do |format|
        format.json { render :json => [], :status => :internal_server_error}
      end
    end

  end

  private

    def matchups_params
      params.permit(:home_team_id, :away_team_id, :game_time, :week_id, :completed, :tie, :winning_team_id, :locked)
    end

end