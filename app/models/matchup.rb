class Matchup < ApplicationRecord

  # may have to specify the fk
  belongs_to :home_team, class_name: "NflTeam"
  belongs_to :away_team, class_name: "NflTeam"
  belongs_to :week
  has_many :picks
  validates_presence_of :week
  validates_presence_of :home_team
  validates_presence_of :away_team


  def self.handle_matchup_outcome!(matchup_id)
    @matchup = Matchup.find_by(id: matchup_id)
    @this_matchups_picks = @matchup.picks
    if @this_matchups_picks.empty?
      @matchup.completed = true
      @matchup.save!
    else
      @this_matchups_picks.each do |pick|
        if @matchup.tie == true
          Matchup.handle_tie_game(@matchup, pick)
        elsif @matchup.winning_team_id == pick.team_id
          Matchup.handle_winning_outcome(@matchup, pick)
        elsif @matchup.winning_team_id != pick.team_id
          Matchup.handle_losing_outcome(@matchup, pick)
        end
      end
    end
  end

private

  def self.handle_tie_game(matchup, pick)
    pick.pool_entry.knocked_out = true
    pick.pool_entry.knocked_out_week_id = matchup.week_id
    pick.save!
    matchup.completed = true
    matchup.save!
  end

  def self.handle_winning_outcome(matchup, pick)
    # Send email message or give some other notification that a person will continue?
    matchup.completed = true
    matchup.save!
  end

  def self.handle_losing_outcome(matchup, pick)
    pick.pool_entry.knocked_out = true
    pick.pool_entry.knocked_out_week_id = matchup.week_id
    pick.save!
    matchup.completed = true
    matchup.save!
  end

end
