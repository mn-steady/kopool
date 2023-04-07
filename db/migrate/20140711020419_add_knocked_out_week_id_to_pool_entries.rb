class AddKnockedOutWeekIdToPoolEntries < ActiveRecord::Migration[7.0]
  def change
  	add_column :pool_entries, :knocked_out_week_id, :integer
  end
end
