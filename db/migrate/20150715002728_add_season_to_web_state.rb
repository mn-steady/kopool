class AddSeasonToWebState < ActiveRecord::Migration[7.0]
  def change
  	add_column :web_states, :season_id, :integer
  end
end
