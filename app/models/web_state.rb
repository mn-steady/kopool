class WebState < ApplicationRecord

  belongs_to :current_week, class_name: "Week", :foreign_key => "week_id"
  belongs_to :current_season, class_name: "Season", :foreign_key => "season_id"

  validate :only_one_record?, :on => :create
  validate :season_matches_week, :on => :update

  delegate :open_for_picks, to: :current_week

  private

  def only_one_record?
    self.errors[:base] << "There can only be one WebState record" if WebState.count > 0
  end

  def season_matches_week
  	unless current_week.season_id == current_season.id
  		self.errors[:base] << "Current week must be in the current season."
  	end
  end
end

