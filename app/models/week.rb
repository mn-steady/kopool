class Week < ActiveRecord::Base
	has_many :matchups
	has_many :picks
	belongs_to :season
	belongs_to :default_team, class_name: :nfl_team

	WEEKS_IN_SEASON = 17

	validates_presence_of :week_number
	validates_presence_of :start_date
	validates_presence_of :end_date
	validates_presence_of :deadline
	validates_presence_of :season_id

	validates :week_number, uniqueness: {scope: :season_id}, presence: true

	def close_week_for_picks!
		self.update_attributes(open_for_picks: false)
	end

	def reopen_week_for_picks!
		# This can only be done if this is still the current week
		if WebState.first.week_id == self.id
			self.update_attributes(open_for_picks: true)
			return true
		else
			Rails.logger.error("Cannot reopen week " + self.id + "because current week is id " + WebState.first.week_id )
			return false
		end
	end

	def move_to_next_week!
		season = self.season
		webstate = WebState.first
		if self.id == webstate.week_id
			self.close_week_for_picks!
			self.update_attributes(current_week: false)
			# TODO: Decide what we want to do to end a season
			if self.week_number < WEEKS_IN_SEASON # Don't error out if this is the last week in the season
				next_week_number = self.week_number + 1
				next_week = Week.where(season: season).where(week_number: next_week_number).first
				next_week.update_attributes(current_week: true)
				webstate.update_attributes(week_id: next_week.id)
				return true
			else
				Rails.logger.debug("We have reached the end of the season")
				# TODO: Automatically close the season?
				return true
			end
		else
			Rails.logger.error("(Week.move_to_next_week!) CRITICAL ERROR: WEEK NUMBER MISMATCH")
			return false
		end
	end
end
