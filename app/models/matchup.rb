class Matchup < ActiveRecord::Base

  # may have to specify the fk
  belongs_to :home_team, class_name: "NflTeam"
  belongs_to :away_team, class_name: "NflTeam"
  belongs_to :week
  validates_presence_of :week
  validates_presence_of :home_team
  validates_presence_of :away_team


end
