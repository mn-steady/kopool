class Season < ApplicationRecord
	has_many :weeks
	has_many :pool_entries

	validates :entry_fee, :year, presence: true
	validates :name, presence: true, uniqueness: { scope: :year }
end
