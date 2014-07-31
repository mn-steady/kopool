class PoolEntry < ActiveRecord::Base
	has_many :picks
	has_many :payments
  belongs_to :user
  belongs_to :season

  validates_uniqueness_of :team_name, scope: :season_id

	validates_presence_of :user_id
	validates_presence_of :team_name
end
