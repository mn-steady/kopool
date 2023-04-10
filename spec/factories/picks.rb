FactoryBot.define do
  factory :pick do
    pool_entry
    week
    matchup
    nfl_team { create(:nfl_team) }
    auto_picked { false }
  end
end
