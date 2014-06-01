class AddActiveForScoringToWeeks < ActiveRecord::Migration
  def change
  	add_column :weeks, :active_for_scoring, :boolean, default: true
  end
end
