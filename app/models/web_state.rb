class WebState < ActiveRecord::Base

  belongs_to :current_week, class_name: "Week", :foreign_key => "week_id"

  validate :only_one_record?

  private

  def only_one_record?
    self.errors[:base] << "There can only be one WebState record" if WebState.count > 0
  end
end

