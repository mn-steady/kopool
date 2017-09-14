class Pick < ActiveRecord::Base
	belongs_to :week
	belongs_to :nfl_team, foreign_key: :team_id
	belongs_to :pool_entry, autosave: true
	belongs_to :matchup

	validates_presence_of :team_id, :pool_entry_id, :week_id, :matchup_id
	validates_uniqueness_of :pool_entry_id, scope: :week_id

  validate :cannot_change_locked_in_pick, :on => :update
  validate :cannot_change_knocked_out_pick, :on => :update
  validate :cannot_change_pick_during_closed_week, :on => :update

  validate :pick_must_be_in_matchup

  def user
    pool_entry.user
  end

  private

  def pick_must_be_in_matchup
    matchup = Matchup.where(id: self.matchup_id).first
    return true unless matchup.present?
    return true if (matchup.home_team_id == self.team_id or matchup.away_team_id == self.team_id)
    self.errors[:base] << "The pick must either be the home_team or away_team"
  end

  def cannot_change_locked_in_pick
    if self.locked_in? and self.changed_attributes['team_id'].present?
      self.errors[:base] << "You cannot change a locked_in pick "
    end
  end

  def cannot_change_knocked_out_pick
    if self.pool_entry.knocked_out? and self.changed_attributes['team_id'].present?
      self.errors[:base] << "You cannot change a pick when knocked out "
    end
  end

  def cannot_change_pick_during_closed_week
    if !self.week.open_for_picks? and self.changed_attributes['team_id'].present?
      self.errors[:base] << "You cannot change a pick when the week is closed "
    end
  end
end
