FactoryGirl.define do
  factory :week do
    season
    week_number { "#{rand(51)}" }
    start_date Date.today + 10.days
    end_date Date.today + 15.days
    deadline Date.today + 14.days
  end
end
