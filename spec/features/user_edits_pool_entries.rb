require 'spec_helper'

feature "brand new user registers", js: true do

  before do
    @admin = create(:user, admin: true)
    @user = create(:user, email: 'user@example.com', password: 'password', password_confirmation: 'password')
    @season = Season.create(year: 2014, name: "2015 Season", entry_fee: 50, open_for_registration: true)
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

  scenario 'create two new pool entries', js: true do
    current_user = @user
    visit root_path
    angular_login(current_user)
    click_link("add-entries")

    expect(find('#entry-count')).to have_content "0"
    page.find("#add-entry").click
    expect(find('#entry-count')).to have_content "1"
    fill_in 'pool-entry-0', with: 'My First Team'
    page.find('#save-entry-0').click
    expect(page).to have_content "My First Team"

    page.find("#add-entry").click
    expect(find('#entry-count')).to have_content "2"
    fill_in 'pool-entry-1', with: 'My Second Team'
    page.find('#save-entry-1').click
    expect(page).to have_content "My Second Team"

    page.find('#save-and-return').click
    click_link("add-entries")
    expect(find('#entry-count')).to have_content "2"
    expect(page).to have_content "My First Team"
    expect(page).to have_content "My Second Team"
  end
end
