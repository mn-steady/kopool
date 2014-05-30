class AddCurrentWeekToWeek < ActiveRecord::Migration
  def change
  	add_column :weeks, :current_week, :boolean, default: false
  end
end
