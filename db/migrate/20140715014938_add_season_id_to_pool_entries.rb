class AddSeasonIdToPoolEntries < ActiveRecord::Migration[7.0]
  def change
  	add_column :pool_entries, :season_id, :integer
  end
end
