class PoolEntriesController < ApplicationController

  before_filter :verify_admin_user, only: [:show, :update, :destroy]
  before_filter :verify_any_user, only: [:index, :create, :index_even_knocked_out]

  def index
    Rails.logger.debug("(PoolEntriesController.index) is user")
    @pool_entries = PoolEntry.where(user: current_user, knocked_out: false)

    respond_to do | format |
      format.json {render json: @pool_entries}
    end
  end

  def index_all
    Rails.logger.debug("(PoolEntriesController.index_even_knocked_out) is user")
    @pool_entries = PoolEntry.where(user: current_user)

    respond_to do | format |
      format.json {render json: @pool_entries}
    end
  end

  def create
    Rails.logger.debug("(PoolEntries.create)")
    cleaned_params = pool_entries_params
    @pool_entry = PoolEntry.new(user: current_user, team_name: cleaned_params[:team_name])
    @web_state = WebState.first
    @week = Week.find(@web_state.week_id)
    @season = @week.season

    @pool_entry.season_id = @season.id

    # @pool_entry.update_attributes(pool_entries_params)

    if @week.week_number != 1
      respond_to do | format |
        error_message = "You cannot create pool entries after the first week has started"
        @pool_entry.errors.each{|attr,msg| error_message << "#{attr} #{msg} " }
        format.json { render :json => [:error => error_message], :status => :bad_request}
      end
    elsif @week.week_number == 1 and @week.open_for_picks == false
      respond_to do | format |
        error_message = "You cannot create pool entries after the season has started"
        @pool_entry.errors.each{|attr,msg| error_message << "#{attr} #{msg} " }
        format.json { render :json => [:error => error_message], :status => :bad_request}
      end
    elsif @pool_entry.save()
      respond_to do | format |
        format.json {render json: @pool_entry}
      end
    else
      respond_to do | format |
        error_message = ""
        @pool_entry.errors.each{|attr,msg| error_message << "#{attr} #{msg} " }
        format.json { render :json => [:error => error_message], :status => :internal_server_error}
      end
    end
  end

  def update
    Rails.logger.debug("PoolEntries.update")
    @pool_entry = PoolEntry.find(params[:id])

    @pool_entry.update_attributes(pool_entries_params)

    if @pool_entry.save
      respond_to do | format |
        format.json {render json: @pool_entry }
      end
    else
      respond_to do | format |
        error_message = ""
        @pool_entry.errors.each{ |attr,msg| error_message << "#{attr} #{msg}" }
        format.json { render :json => [:error => error_message], :status => :bad_request}
      end
    end
  end

private

  def pool_entries_params
    params.permit(:id, :user_id, :team_name, :paid)
  end

end