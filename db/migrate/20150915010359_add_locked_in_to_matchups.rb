class AddLockedInToMatchups < ActiveRecord::Migration
  def change
  	add_column :matchups, :locked_in, :boolean
  end
end
