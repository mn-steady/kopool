class PoolEntry < ActiveRecord::Base
	has_many :picks
	has_many :payments
  belongs_to :user
	validates_uniqueness_of :team_name
end
