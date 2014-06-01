class RenameOpenInWeeks < ActiveRecord::Migration
  def self.up
  	rename_column :weeks, :open, :open_for_picks
  	change_column_default :weeks, :open_for_picks, true
  end

  def self.down
  	change_column_default :weeks, :open_for_picks, nil
  	rename_column :weeks, :open_for_picks, :open
  end
end
