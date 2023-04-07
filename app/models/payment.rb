class Payment < ApplicationRecord
	validates :amount, presence: true
end
