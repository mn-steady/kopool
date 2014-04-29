class SeasonsController < ApplicationController
	before_action :require_user

	def new
		@season = Season.new
	end
end