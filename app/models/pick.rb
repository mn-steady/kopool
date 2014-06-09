class Pick < ActiveRecord::Base
	belongs_to :week
	belongs_to :nfl_team, foreign_key: :team_id
	belongs_to :pool_entry

	validates_presence_of :team_id, :pool_entry_id, :week_id
	validates_uniqueness_of :pool_entry_id, scope: :week_id
end
