class PoolEntriesController < ApplicationController


  before_filter :verify_admin_user, only: [:show, :update, :create, :destroy]
  before_filter :verify_any_user, only: [:index]

  def index

    Rails.logger.debug("(PoolEntriesController.index) is user")
    @pool_entries = PoolEntry.all

    respond_to do | format |
      format.json {render json: @pool_entries}
    end

  end

end