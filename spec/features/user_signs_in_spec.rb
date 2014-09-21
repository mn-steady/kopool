require 'spec_helper'

feature "user signs in", js: true do
	scenario "with valid email and password" do
		user = create(:user)
    visit root_path
    fill_in 'sign_on_field', with: user.email
    fill_in 'password_field', with: user.password

    click_button("Sign In")

    expect(page).not_to have_content("Sign In")
    expect(page).to have_content(user.email)
	end
end