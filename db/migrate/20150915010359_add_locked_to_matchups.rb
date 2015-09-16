class AddLockedToMatchups < ActiveRecord::Migration
  def change
  	add_column :matchups, :locked, :boolean
  end
end
