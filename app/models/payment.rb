class Payment < ApplicationRecord
	validates_presence_of :amount
end
