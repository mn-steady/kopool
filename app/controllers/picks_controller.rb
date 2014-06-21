class PicksController < ApplicationController
	before_filter :verify_any_user, only: [:create, :update]

	def index

		Rails.logger.debug("PicksController.this_weeks_picks")
		@picks = Pick.where(week_id: params[:week_id]).joins(:pool_entry).where('pool_entries.user_id = ?', current_user.id)

		respond_to do | format |
			format.json {render :json => @picks.to_json(include: [{pool_entry: {only: [:id, :team_name] }}, nfl_team: {only: [:id, :name]}] ) }
		end

	end

	def create
		Rails.logger.debug("Picks.create")
		@pick = Pick.new

		@pick.update_attributes(picks_params)

		if @pick.save
			respond_to do | format |
				format.json {render json: @pick }
			end
		else
			respond_to do | format |
				error_message = ""
				@pick.errors.each{ |attr,msg| error_message << "#{attr} #{msg}" }
				format.json { render :json => [:error =>  error_message], :status => :internal_server_error}
			end
		end
	end

	def update
		Rails.logger.debug("Picks.update")
		@pool_entry = PoolEntry.find(params[:pool_entry_id])
		@pick = Pick.where(week_id: params[:week_id], pool_entry_id: params[:pool_entry_id]).first unless current_user.id != @pool_entry.user_id
		
		@pick.update_attributes(picks_params)

		if @pick.save
			respond_to do | format |
				format.json {render json: @pick }
			end
		else
			respond_to do | format |
				error_message = ""
				@pick.errors.each{ |attr,msg| error_message << "#{attr} #{msg}" }
				format.json { render :json => [:error =>  error_message], :status => :internal_server_error}
			end
		end
	end

	private

	def picks_params
		params.permit(:pool_entry_id, :week_id, :team_id, :locked_in, :auto_picked)
	end


end