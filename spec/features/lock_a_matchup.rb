require 'spec_helper'

feature "pick and score a week", js: true do

  before do

    @user = create(:user)
    @admin = create(:user, admin: true)
    @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
    @week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
    @week2 = Week.create(season: @season, week_number: 2, start_date: DateTime.new(2014, 8, 14), deadline: DateTime.new(2014, 8, 15), end_date: DateTime.new(2014, 8, 17))
    @webstate = WebState.create(week_id: @week.id, season_id: @season.id)
    @pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true, season_id: @season.id)
    @pool_entry2 = PoolEntry.create(user: @user, team_name: "Test Team 2", paid: true, season_id: @season.id)

    @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
    @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
    @matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))

    @colts = NflTeam.create(name: "Indianapolis Colts", conference: "AFC", division: "West")
    @chargers = NflTeam.create(name: "San Diego Chargers", conference: "AFC", division: "North")
    @matchup2 = Matchup.create(week_id: @week.id, home_team: @colts, away_team: @chargers, game_time: DateTime.new(2014,8,14,11))

  end

  scenario "with an open week", js: true do
    current_user = @user
    visit root_path
    angular_login(current_user)

    click_link("Picks")

    # Select Pick for first Pool Entry

    find(:css, "#select-pick-#{@pool_entry1.id}").click
    find(:css, "#select-home-#{@matchup.id}").click
    find(:css, "#save-matchup-#{@matchup.id}").click

    expect(page).to have_content("Denver Broncos")

    # Select Pick for second Pool Entry

    find(:css, "#select-pick-#{@pool_entry2.id}").click
    find(:css, "#select-home-#{@matchup2.id}").click
    find(:css, "#save-matchup-#{@matchup2.id}").click

    expect(page).to have_content("Indianapolis Colts")

    # Switch to Admin User

    angular_logout(current_user)
    angular_login(@admin)

    click_link("Commissioner")
    select 'Minnesota Vikings at Denver Broncos: Locked = false', :from => 'lock-select'
    click_button("LOCK Matchup")
    expect(page).to have_content("Saved Matchup Minnesota Vikings vs. Denver Broncos - Locked = true")

    angular_logout(@admin)
    angular_login(@user)

    click_link("Picks")

    find(:css, "#select-pick-#{@pool_entry2.id}").click
    expect(page).to have_content("Game is Locked!")

  end
end