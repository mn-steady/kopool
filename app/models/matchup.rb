class Matchup < ActiveRecord::Base

  # may have to specify the fk
  belongs_to :home_team, class_name: "NflTeam"
  belongs_to :away_team, class_name: "NflTeam"
  belongs_to :week


end
