FactoryGirl.define do
  factory :nfl_team do
    sequence(:name) { |n| "TEST TEAM #{n}" }
    conference "NFC"
    division "North"
  end
end
