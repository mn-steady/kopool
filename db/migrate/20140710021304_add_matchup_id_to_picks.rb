class AddMatchupIdToPicks < ActiveRecord::Migration
  def change
  	add_column :picks, :matchup_id, :integer
  end
end
