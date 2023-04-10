class AddActiveForScoringToWeeks < ActiveRecord::Migration[7.0]
  def change
  	add_column :weeks, :active_for_scoring, :boolean, default: true
  end
end
