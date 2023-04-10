FactoryBot.define do
  factory :pool_entry do
    user
    season
    sequence(:team_name) { |n| "Pool Entry #{n}" }
  end
end
