class AddLockedToMatchups < ActiveRecord::Migration[7.0]
  def change
  	add_column :matchups, :locked, :boolean
  end
end
