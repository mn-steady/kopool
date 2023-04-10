FactoryBot.define do
	factory :user do
		email { Faker::Internet.email }
		phone { Faker::PhoneNumber.phone_number }
		cell { Faker::PhoneNumber.cell_phone }
		password { "crazyemail8" }
		password_confirmation { "crazyemail8" }
		association :favorite_team, factory: :nfl_team
	end

	factory :admin, class: User do
		email { Faker::Internet.email }
		phone { Faker::PhoneNumber.phone_number }
		cell { Faker::PhoneNumber.cell_phone }
		password { "crazyemail8" }
		password_confirmation { "crazyemail8" }
		admin { true }
		association :favorite_team, factory: :nfl_team
	end

	factory :season do
		year { Faker::Number.number(digits: 4) }
		name { Faker::Lorem.words(number: 2).join(' ') }
		entry_fee { Faker::Number.number(digits: 2) }
	end
end
