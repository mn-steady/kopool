class Payment < ActiveRecord::Base
	validates_presence_of :amount
end
