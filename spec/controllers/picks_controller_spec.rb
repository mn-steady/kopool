require 'spec_helper'

describe PicksController do

  pending "should gracefully trap if user attempts to change after locked_in"

  describe "GET index" do

  	before do
			@user = create(:user, admin: true)
			sign_in :user, @user

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true)
			@pool_entry2 = PoolEntry.create(user: @user, team_name: "Team Two", paid: true)

			@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
		end

  	pending "sets @picks to the user's picks from this season" do
  		pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
  		pick2 = Pick.create(pool_entry: @pool_entry2, week: @week, team_id: @broncos.id)
  		get :index, week_id: @week.id # This isn't working for some reason
  		expect(@picks).to eq([pick1, pick2])

  	end
  	it "does not include another user's picks in @picks"
  	it "does not include picks from a different season in @picks"
  end

  describe "POST create" do

  	context "with a valid pool entry" do

	  	context "with valid input" do
	  		it "redirects to the My Picks page"
	  		it "saves the pick"
	  		it "sets the flash success message"
	  	end


	  	context "with invalid input" do # i.e. after deadline (should I create separate tests?)
	  		it "does not create a new pick"

	  		# A previously saved pick is not overwritten if you try to change after the deadline
	  		it "does not invalidate an already saved pick"
	  		it "redirects to the matchup page"
	  		it "sets a flash danger message"
	  	end

	  end

	  context "with an unpaid pool entry" do
	  	it "does save the pick"
	  	it "redirects to the My Picks page"
	  	it "sets a flash warning message about the unpaid balance"
	  end

	  context "with a knocked out pool entry" do
	  	it "does not save the pick"
	  	it "redirects to the matchup page"
	  	it "sets a flash danger message"
	  end
  end

  describe "GET missing_picks" do
  	# Will we want this in pool_entries_controller since we'll search
  	# for pool_entries without a pick for that week?
  	it "sets @missing_picks to the missing picks from the current week"
  	it "does not include picks from a later week in @missing_picks"
  	it "does not include completed picks in @missing_picks"
  end

end