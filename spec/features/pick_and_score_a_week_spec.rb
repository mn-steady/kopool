require 'spec_helper'

feature "pick and score a week", js: true do

  before do

    @user = create(:user)
    @admin = create(:user, admin: true)
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

  scenario "with an open week", js: true do
    current_user = @user
    login_as current_user, scope: :user
    visit root_path

    click_button("Sign In")
    click_link("Your Picks")

    # Select Pick for first Pool Entry

    find(:css, "#select-pick-#{@pool_entry1.id}").click
    find(:css, "#select-home-#{@matchup.id}").click
    find(:css, "#save-matchup-#{@matchup.id}").click

    expect(page).to have_content("Denver Broncos")

    # Select Pick for second Pool Entry

    find(:css, "#select-pick-#{@pool_entry2.id}").click
    find(:css, "#select-home-#{@matchup.id}").click
    find(:css, "#save-matchup-#{@matchup.id}").click

    expect(page).to have_content("Denver Broncos")

    # Select Pick for third Pool Entry

    find(:css, "#select-pick-#{@pool_entry3.id}").click
    find(:css, "#select-home-#{@matchup2.id}").click
    find(:css, "#save-matchup-#{@matchup2.id}").click

    expect(page).to have_content("Indianapolis Colts")

    # Switch to Admin User

    logout(current_user)
    click_button("#{@user.email}")
    find('a', :text => "Sign Out").click
    visit root_path
    angular_login(@admin)

    click_link("Commissioner")
    click_button("Close for Picks")

    # Need to sign out and in again because of bug in the browser cookie

    angular_logout(@admin)

    angular_login(@admin)

    click_link("Score Matchups")

    # Score Matchups

    find(:css, "#select-away-#{@matchup.id}").click
    find(:css, "#save-outcome-#{@matchup.id}").click
    find('button', :text => "Save Outcome").click

    sleep(1)

    find(:css, "#select-home-#{@matchup2.id}").click
    find(:css, "#save-outcome-#{@matchup2.id}").click
    find('button', :text => "Save Outcome").click

    expect(page).to have_content("Winner: Minnesota Vikings")
    expect(page).to have_content("Winner: Indianapolis Colts")

    # View Results as End User

    angular_logout(@admin)
    angular_login(@user)

    click_link("Results")

    expect(page).to have_content("Knocked Out This Week: 2")
    expect(page).to have_content("Still Alive: 1")

    angular_logout(@user)

    # Move to next week

    fill_in 'sign_on_field', with: @admin.email
    fill_in 'password_field', with: @admin.password
    click_button("Sign In")
    click_link("Commissioner")
    click_button("Move to Next Week")
    find('button', :text => "Advance Week").click

    angular_logout(@admin)

    # User should only have one pool entry left

    angular_login(@user)
    click_link("Your Picks")

    expect(page).to have_content("Test Team 3")
    expect(page).not_to have_content("Test Team 2")
  end

  def angular_logout(user)
    logout(user)
    click_button("#{user.email}")
    find('a', :text => "Sign Out").click
    visit root_path
  end

  def angular_login(user)
    fill_in 'sign_on_field', with: user.email
    fill_in 'password_field', with: user.password
    click_button("Sign In")
  end
end