require 'spec_helper'

feature "brand new user registers", js: true do

  before do
    @admin = create(:user, admin: true)
    @season = Season.create(year: 2014, name: "2015 Season", entry_fee: 50)
    @week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
    @week2 = Week.create(season: @season, week_number: 2, start_date: DateTime.new(2014, 8, 14), deadline: DateTime.new(2014, 8, 15), end_date: DateTime.new(2014, 8, 17))
    @webstate = WebState.create(week_id: @week.id, season_id: @season.id)

    @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
    @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
    @matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))

    @colts = NflTeam.create(name: "Indianapolis Colts", conference: "AFC", division: "West")
    @chargers = NflTeam.create(name: "San Diego Chargers", conference: "AFC", division: "North")
    @matchup2 = Matchup.create(week_id: @week.id, home_team: @colts, away_team: @chargers, game_time: DateTime.new(2014,8,14,11))
  end

  scenario 'when season is open for registration', js: true do
    @season.update_attribute :open_for_registration, true
    visit root_path
    expect(page).to have_content "Register"
    click_link("Register")

    fill_in 'name', with: "New User"
    fill_in 'phone', with: "763-222-0011"
    fill_in 'email', with: "newuser@example.com"
    fill_in 'password', with: "password"
    fill_in 'password-confirmation', with: "password"
    find(:css, "#register").click

    expect(page).to have_content "Round"
    expect(page).to have_content "Remaining"
    expect(page).to have_content "Payout"
  end

  scenario 'when season is not open for registration', js: true do
    @season.update_attribute :open_for_registration, false
    visit root_path
    expect(page).not_to have_content "Register"
  end
end
