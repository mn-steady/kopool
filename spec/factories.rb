FactoryGirl.define do
	factory :user do
		email { Faker::Internet.email }
		phone { Faker::PhoneNumber.phone_number }
		cell { Faker::PhoneNumber.cell_phone }
		password "password"
		password_confirmation "password"
	end
end