class AddCurrentWeekToWeek < ActiveRecord::Migration[7.0]
  def change
  	add_column :weeks, :current_week, :boolean, default: false
  end
end
