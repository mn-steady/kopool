class AddMatchupIdToPicks < ActiveRecord::Migration[7.0]
  def change
  	add_column :picks, :matchup_id, :integer
  end
end
