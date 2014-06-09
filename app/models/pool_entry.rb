class PoolEntry < ActiveRecord::Base
	has_many :picks
	has_many :payments
  belongs_to :user
	validates_uniqueness_of :team_name

	validates_presence_of :user_id
	validates_presence_of :team_name
end
