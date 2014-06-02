class Week < ActiveRecord::Base
	has_many :matchups
	belongs_to :season

	WEEKS_IN_SEASON = 17

	validates_presence_of :week_number
	validates_presence_of :start_date
	validates_presence_of :end_date
	validates_presence_of :deadline
	validates_presence_of :season_id

	def close_week_for_picks!
		self.update_attributes(open_for_picks: false)
	end

	def move_to_next_week!
		season = self.season
		self.update_attributes(current_week: false)
		# TODO: Decide what we want to do to end a season
		if self.week_number < WEEKS_IN_SEASON # Don't error out if this is the last week in the season
			next_week_number = self.week_number + 1
			next_week = Week.where(season: season).where(week_number: next_week_number).first
			next_week.update_attributes(current_week: true)
		else
			Rails.logger.error = "We have reached the end of the season"
		end
	end
end
