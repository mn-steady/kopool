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

end