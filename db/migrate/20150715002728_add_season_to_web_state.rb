class AddSeasonToWebState < ActiveRecord::Migration
  def change
  	add_column :web_states, :season_id, :integer
  end
end
