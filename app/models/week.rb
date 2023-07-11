class Week < ApplicationRecord
	has_many :matchups
	has_many :picks
	belongs_to :season
	belongs_to :default_team, class_name: 'NflTeam', optional: true

	WEEKS_IN_SEASON = 17
	SQL_DOW_MONDAY = 1

	validates :start_date, :end_date, :deadline, :season_id, presence: true
	validates :week_number, uniqueness: { scope: :season_id }, presence: true

	def self.autopick_matchup_during_week(week_id)
		Matchup.where(week_id: week_id).where('EXTRACT (dow from game_time) = ?', SQL_DOW_MONDAY).order(:game_time).first
	end

	def close_week_for_picks!
		self.update(open_for_picks: false)
	end

	def reopen_week_for_picks!
		# This can only be done if this is still the current week
		if WebState.first.week_id == self.id
			self.update(open_for_picks: true)
			return true
		else
			Rails.logger.error("Cannot reopen week " + self.id + "because current week is id " + WebState.first.week_id )
			return false
		end
	end

	def move_to_next_week!
		season = self.season
		webstate = WebState.first
		if self.id == webstate.week_id
			self.close_week_for_picks!
			autopick_if_missing!(self)
			# TODO: Decide what we want to do to end a season
			if self.week_number < WEEKS_IN_SEASON # Don't error out if this is the last week in the season
				next_week_number = self.week_number + 1
				next_week = Week.where(season: season).where(week_number: next_week_number).first
				webstate.update(week_id: next_week.id)
				next_week.reopen_week_for_picks!
				return true
			else
				Rails.logger.error("We have reached the end of the season")
				# TODO: Automatically close the season?
				return true
			end
		else
			Rails.logger.error("(Week.move_to_next_week!) CRITICAL ERROR: WEEK NUMBER MISMATCH")
			return false
		end
	end

private

	def autopick_if_missing!(week)
		pool_entries_need_autopicks = PoolEntry.needs_autopicking(week)
		if pool_entries_need_autopicks.present?
			robo_matchup = Week.autopick_matchup_during_week(week.id)
			if robo_matchup.present?
				pool_entries_need_autopicks.each do | robopick |
					p = Pick.where(week_id: week.id).where(pool_entry_id: robopick.id).first
					if p.nil?
						autopick = Pick.new(pool_entry_id: robopick.id, week_id: week.id, team_id: robo_matchup.home_team_id, auto_picked: true, matchup_id: robo_matchup.id)
						autopick.save!
					else
						Rails.logger.error("(Week.autopick_if_missing!) ERROR: Pick needing autopick had a pick already")
					end
				end
			else
				Rails.logger.error("(Week.autopick_if_missing!)  ERROR: No autopick_matchup_during_week found")
			end
		end
	end

end
