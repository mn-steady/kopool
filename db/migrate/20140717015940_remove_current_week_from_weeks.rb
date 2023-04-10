class RemoveCurrentWeekFromWeeks < ActiveRecord::Migration[7.0]
  def change
  	remove_column :weeks, :current_week
  end
end
