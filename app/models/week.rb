class Week < ActiveRecord::Base
	has_many :matchups
	belongs_to :season

	validates_presence_of :week_number
	validates_presence_of :start_date
	validates_presence_of :end_date
	validates_presence_of :deadline
	validates_presence_of :season_id

	def close_week_for_picks
		self.open_for_picks = false
	end
end
