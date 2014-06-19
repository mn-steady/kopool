class PoolEntriesController < ApplicationController

  before_filter :verify_admin_user, only: [:show, :update, :create, :destroy]
  before_filter :verify_any_user, only: [:index]

  def index

    Rails.logger.debug("(PoolEntriesController.index) is user")
    @pool_entries = PoolEntry.where(user: current_user)

    respond_to do | format |
      format.json {render json: @pool_entries} # Return this week's picks as well
    end
  end

  def create
    Rails.logger.debug("(PoolEntries.create)")
    cleaned_params = pool_entries_params
    @pool_entry = PoolEntry.new(user: current_user, team_name: cleaned_params[:team_name])

    # @pool_entry.update_attributes(pool_entries_params)

    if @pool_entry.save()
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

private

  def pool_entries_params
    params.permit(:id, :user_id, :team_name)
  end

end