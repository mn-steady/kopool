class Matchup < ActiveRecord::Base

  # may have to specify the fk
  has_one :home_team, class_name: "NflTeam"
  has_one :away_team, class_name: "NflTeam"


end
