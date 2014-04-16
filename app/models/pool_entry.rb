class PoolEntry < ActiveRecord::Base
	has_many :picks
	has_many :payments
	validates_uniqueness_of :team_name
end
