class PoolEntry < ActiveRecord::Base
	has_many :picks
	has_many :payments
  belongs_to :user
  belongs_to :season

  validates_uniqueness_of :team_name, scope: :season_id

	validates_presence_of :user_id
	validates_presence_of :team_name

  def self.needs_autopicking(week)
    pools_have_picked = Pick.where(week_id: week.id).pluck(:pool_entry_id)
    PoolEntry.where(season: week.season).where(knocked_out: false).where.not(id: pools_have_picked).order(:id)
  end

end
