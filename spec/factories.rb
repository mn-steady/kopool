FactoryGirl.define do
	factory :user do
		email { Faker::Internet.email }
		phone { Faker::PhoneNumber.phone_number }
		cell { Faker::PhoneNumber.cell_phone }
		password "password"
		password_confirmation "password"
	end

	factory :season do
		year { Faker::Number.number(4) }
		name { Faker::Lorem.words(2).to_s }
		entry_fee { Faker::Number.number(2) }
	end
end