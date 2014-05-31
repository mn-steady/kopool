class Week < ActiveRecord::Base
	has_many :matchups
	belongs_to :season

	validates_presence_of :week_number
	validates_presence_of :start_date
	validates_presence_of :end_date
	validates_presence_of :deadline
	validates_presence_of :season_id

	def close_week_for_picks!
		self.open_for_picks = false
		self.save!
	end

	def move_to_next_week!
		season = self.season
		self.update_attributes(current_week: false)
		# weeks_in_the_season = season.weeks.order(:week_number)
		# this_week = weeks_in_the_season.index(self)
		# next_week = weeks_in_the_season[this_week+1]
		# next_week.current_week = true
		next_week_number = self.week_number + 1
		next_week = Week.where(season: season).where(week_number: next_week_number).first
		next_week.update_attributes(current_week: true)
	end
end
