class ChangeNflTeamLogo < ActiveRecord::Migration
  def self.up
    remove_column :nfl_teams, :logo
    add_attachment :nfl_teams, :logo
  end

  def self.down
    remove_attachment :nfl_teams, :logo
    add_column :nfl_teams, :logo, :string
  end
end
