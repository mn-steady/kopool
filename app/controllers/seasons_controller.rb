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

	private

	def season_params
		params.require(:season).permit(:year, :name, :entry_fee)
	end
end