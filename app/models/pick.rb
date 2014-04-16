class Pick < ActiveRecord::Base
	belongs_to :week
	belongs_to :nfl_team, foreign_key: :team_id
	validates_presence_of :team_id
end
