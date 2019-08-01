class SeasonsController < ApplicationController
	before_action :require_user

	def new
		@season = Season.new
	end

	def create
		@season = Season.new(season_params)
		if @season.save
			flash[:success] = "Season Created! Have a fantastic year of football!"
			redirect_to season_path(@season)
		else
			flash[:danger] = "Looks like the input wasn't quite right. Please fix it and try again."
			render :new
		end
	end

	def show
		@season = Season.find(params[:id])
	end

	def season_results
		Rails.logger.debug("seasons_controller.season_results")
		@pool_entries = PoolEntry.where(season_id: params[:season_id]).order('team_name ASC')

		respond_to do |format|
			format.json {render :json => @pool_entries.to_json(include: [{user: {only: [:email, :phone, :name]}}])}
		end
	end

	def season_knockout_counts
		@pool_entries = PoolEntry.where(season_id: params[:season_id]).group(:knocked_out).count

		respond_to do |format|
			format.json {render :json => @pool_entries.to_json}
		end
	end

	def season_summary
		Rails.logger.debug("seasons_controller.season_summary")
		@web_state = WebState.first
		@season = @web_state.current_season
		@total_pool_entries_this_season = PoolEntry.where(season_id: @season.id).count
		@week_number = @web_state.current_week.week_number
		@season_weeks = @season.weeks
		@valid_weeks = @season_weeks.select { |w| w.week_number <= @week_number } # We only want to display current or past weeks on the chart
		@valid_weeks.sort_by! { |w| w.week_number } # Make sure weeks are in the correct order

		@returned_week_numbers_and_values = []

		@pool_entries_knocked_out_so_far = 0

		@valid_weeks.each do |week|
			@returned_week = {}
			@returned_week["x"] = week.week_number.to_s # Need X values to be a string for the chart
			@pool_entries_knocked_out_this_week_count = PoolEntry.where(knocked_out_week_id: week.id).count
			@returned_week["y"] = [@total_pool_entries_this_season - (@pool_entries_knocked_out_this_week_count + @pool_entries_knocked_out_so_far)]
			@pool_entries_knocked_out_so_far += @pool_entries_knocked_out_this_week_count

			@returned_week_numbers_and_values.push(@returned_week)
		end

		respond_to do |format|
			format.json { render :json => @returned_week_numbers_and_values}
		end
	end

	private

	def season_params
		params.require(:season).permit(:year, :name, :entry_fee)
	end
end