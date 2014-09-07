#cleanup_picks_ii.rb
# Cleanup picks where the team is not in that matchup

# select picks.* from picks
# join matchups on picks.matchup_id = matchups.id
# WHERE picks.week_id = 16
# AND  (picks.team_id NOT IN (matchups.away_team_id,  matchups.home_team_id));

badpicks = Pick.where(id: 267).where(week_id: 16).joins(:matchup).where("picks.team_id NOT IN (matchups.away_team_id,  matchups.home_team_id)")

badpicks.each do | badpick |

  # figure out which matchup they must have meant based on that team/week
  matchup = Matchup.where(week_id: badpick.week_id).where(home_team_id: badpick.team_id).first
  if !matchup.present?
    matchup = Matchup.where(week_id: badpick.week_id).where(away_team_id: badpick.team_id).first
  end

  if matchup.present?
    puts "Setting pick id:#{badpick.id} matchup to id:#{matchup.id}"
    fixpick = Pick.where(id: badpick.id).first
    if fixpick.present?
      fixpick.matchup = matchup
      fixpick.save!
    end
  else
    puts "ERROR: could not find a matchup for pick id #{badpick.id} with team id: #{badpick.team_id}"
  end
end


