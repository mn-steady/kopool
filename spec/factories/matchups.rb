FactoryBot.define do
  factory :matchup do
    week
    home_team { create(:nfl_team) }
    away_team { create(:nfl_team) }
    game_time { Date.today + 50.days }
  end
end
