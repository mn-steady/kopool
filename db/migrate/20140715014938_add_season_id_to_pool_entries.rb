class AddSeasonIdToPoolEntries < ActiveRecord::Migration
  def change
  	add_column :pool_entries, :season_id, :integer
  end
end
