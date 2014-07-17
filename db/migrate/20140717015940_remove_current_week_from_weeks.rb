class RemoveCurrentWeekFromWeeks < ActiveRecord::Migration
  def change
  	remove_column :weeks, :current_week
  end
end
