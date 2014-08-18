require 'spec_helper'

feature "user signs in" do
	scenario "with valid email and password" do
		user = create(:user)
    visit root_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign In"

    expect(page).not_to have_content("Sign In")
    expect(page).to have_content(user.email)
	end
end