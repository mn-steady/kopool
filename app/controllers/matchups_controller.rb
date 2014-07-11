class MatchupsController < ApplicationController
	before_filter :verify_admin_user, only: [:show, :update, :save_week_outcomes, :destroy]
  before_filter :verify_any_user, only: [:index]

  def index

    @week = Week.find(params[:week_id])
    @matchups = Matchup.where(week_id: @week.id)

    respond_to do | format |
      format.json {render :json => @matchups.to_json(include: [{ home_team: { only: [:name, :id] }}, away_team: {only: [:name, :id]}] ) }
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
    @matchup = Matchup.find_by(id: params[:matchup][:id])
    @this_matchups_picks = @matchup.picks

    @this_matchups_picks.each do |pick|
      if @matchup.tie == true
        pick.pool_entry.knocked_out = true
        pick.pool_entry.knocked_out_week_id = @matchup.week_id
        pick.save!
        @matchup.completed = true
        @matchup.save!
      elsif @matchup.winning_team_id == pick.team_id
        # Send email message or give some other notification that a person will continue?
        @matchup.completed = true
        @matchup.save!
      elsif @matchup.winning_team_id != pick.team_id
        pick.pool_entry.knocked_out = true
        pick.pool_entry.knocked_out_week_id = @matchup.week_id
        pick.save!
        @matchup.completed = true
        @matchup.save!
      end
    end

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
      params.permit(:home_team_id, :away_team_id, :game_time, :week_id, :completed, :tie, :winning_team_id)
    end
end