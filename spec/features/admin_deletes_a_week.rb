require 'spec_helper'

feature 'admin deletes a week', js: true do
	before do

		@user = create(:user)
		@admin = create(:admin)
		@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
		@week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
		@week2 = Week.create(season: @season, week_number: 2, start_date: DateTime.new(2014, 8, 14), deadline: DateTime.new(2014, 8, 15), end_date: DateTime.new(2014, 8, 17))
		@webstate = WebState.create(week_id: @week.id)
		@pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true, season_id: @season.id)
		@pool_entry2 = PoolEntry.create(user: @user, team_name: "Test Team 2", paid: true, season_id: @season.id)
		@pool_entry3 = PoolEntry.create(user: @user, team_name: "Test Team 3", paid: true, season_id: @season.id)

		@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
		@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
		@matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))

		@colts = NflTeam.create(name: "Indianapolis Colts", conference: "AFC", division: "West")
		@chargers = NflTeam.create(name: "San Diego Chargers", conference: "AFC", division: "North")
		@matchup2 = Matchup.create(week_id: @week.id, home_team: @colts, away_team: @chargers, game_time: DateTime.new(2014,8,14,11))

	end

	scenario "with an incomplete week" do
		current_user = @admin
		visit root_path
		angular_login(current_user)
		click_link("View Weeks")

		find(:css, "#select-delete-#{@week2.id}").click
		find('button', :text => "Delete Week").click
		expect(page).not_to have_content('Score Matchups for Week 2')
		expect(Week.all.count).to eq(1)
	end

	def angular_login(user)
    fill_in 'sign_on_field', with: user.email
    fill_in 'password_field', with: user.password
    click_button("Sign In")
  end
end