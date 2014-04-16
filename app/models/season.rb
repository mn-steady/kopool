class Season < ActiveRecord::Base
	has_many :weeks
	validates_presence_of :entry_fee
end
