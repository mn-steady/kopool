class AddKnockedOutToPoolEntries < ActiveRecord::Migration
  def change
  	add_column :pool_entries, :knocked_out, :boolean, default: false
  end
end
