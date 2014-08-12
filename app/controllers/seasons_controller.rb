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
		@pool_entries = PoolEntry.where(season_id: params[:season_id])

		respond_to do |format|
			format.json {render :json => @pool_entries.to_json(include: [{user: {only: [:email, :cell]}}])}
		end
	end

	private

	def season_params
		params.require(:season).permit(:year, :name, :entry_fee)
	end
end