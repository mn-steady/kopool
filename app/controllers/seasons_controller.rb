class SeasonsController < ApplicationController
	before_action :require_user

	def new
		@season = Season.new
	end

	def create
		@season = Season.new(season_params)
		@season.save
		redirect_to season_path(@season)
	end

	def show
		@season = Season.find(params[:id])
	end

	private

	def season_params
		params.require(:season).permit(:year, :name, :entry_fee)
	end
end