class PopulateWebStateSeasonId < ActiveRecord::Migration
  def up
  	@web_state = WebState.first
  	@web_state.update_attributes(season_id: Season.first.id) if @web_state && @web_state.season_id.nil?
  end

  def down
  	# no-op
  end
end
